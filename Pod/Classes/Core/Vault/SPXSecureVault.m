/*
   Copyright (c) 2015 Shaps Mohsenin. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY Shaps Mohsenin `AS IS' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL Shaps Mohsenin OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SPXSecureVault.h"
#import "SPXSecureSession.h"
#import "SPXDefines.h"
#import "SPXKeychain.h"

NSString *const SPXSecureVaultDidFailAuthenticationPermanently = @"SPXSecureVaultDidFailAuthenticationPermanently";

static NSMutableDictionary *__vaults;
static dispatch_semaphore_t __semaphore;

static inline void spx_kill_semaphore() {
  dispatch_semaphore_signal(__semaphore);
  __semaphore = NULL;
}

@interface SPXSecureVault () <UIActionSheetDelegate>

@property (nonatomic, strong) id <SPXSecureCredential> credential;
@property (nonatomic, strong) SPXSecureTimedSession *timedSession;
@property (nonatomic, assign) Class <SPXSecurePasscodeViewController> passcodeViewControllerClass;
@property (nonatomic, assign) Class vaultSettingsViewControllerClass;
@property (nonatomic, copy) void (^completionBlock)(id <SPXSecureSession> session);
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL success;
@property (nonatomic, assign) NSUInteger currentRetryCount;

@end

@implementation SPXSecureVault

+ (instancetype)defaultVault
{
  static SPXSecureVault *_sharedInstance = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[self alloc] init];
    _sharedInstance.name = @"DefaultVault";
  });
  
  return _sharedInstance;
}

+ (instancetype)vaultNamed:(NSString *)name
{
  if (!__vaults) {
    __vaults = [NSMutableDictionary new];
  }
  
  SPXSecureVault *vault = __vaults[name];
  
  if (!vault) {
    vault = [SPXSecureVault new];
    vault.name = name;
    __vaults[name] = vault;
  }
  
  return vault;
}

- (BOOL)hasCredential
{
  return (self.credential != nil);
}

- (NSString *)persistentKeyForSelector:(SEL)selector
{
  NSString *name = [@"Abracadabra" stringByAppendingPathExtension:self.name];
  return [name stringByAppendingPathExtension:NSStringFromSelector(selector)];
}

- (void)setMaximumRetryCount:(NSUInteger)maximumRetryCount
{
  NSString *key = [self persistentKeyForSelector:@selector(maximumRetryCount)];
  [[NSUserDefaults standardUserDefaults] setInteger:maximumRetryCount forKey:key];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDefaultTimeoutInterval:(NSTimeInterval)defaultTimeoutInterval
{
  NSString *key = [self persistentKeyForSelector:@selector(defaultTimeoutInterval)];
  [[NSUserDefaults standardUserDefaults] setDouble:MAX(defaultTimeoutInterval, 0) forKey:key];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  [self.timedSession invalidate];
}

- (NSUInteger)maximumRetryCount
{
  NSString *key = [self persistentKeyForSelector:@selector(maximumRetryCount)];
  NSInteger maximumRetryCount = [[NSUserDefaults standardUserDefaults] integerForKey:key];
  return maximumRetryCount ?: 10;
}

- (NSTimeInterval)defaultTimeoutInterval
{
  NSString *key = [self persistentKeyForSelector:@selector(defaultTimeoutInterval)];
  NSInteger defaultTimeoutInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:key];
  return defaultTimeoutInterval ?: 60;
}

- (void)registerPasscodeViewControllerClass:(Class<SPXSecurePasscodeViewController>)viewControllerClass
{
  self.passcodeViewControllerClass = viewControllerClass;
}

- (void)registerVaultSettingsViewControllerClass:(Class)viewControllerClass
{
  self.vaultSettingsViewControllerClass = viewControllerClass;
}

- (void)authenticateWithPolicy:(SPXSecurePolicy)policy completion:(void (^)(id<SPXSecureSession>))completion
{
  [self authenticateWithPolicy:policy description:nil credential:nil completion:completion];
}

- (void)authenticateWithPolicy:(SPXSecurePolicy)policy description:(NSString *)description credential:(id<SPXSecureCredential>)credential completion:(void (^)(id<SPXSecureSession>))completion
{
  if ([self isLocked]) {
    SPXLog(@"The vault has been locked because the user entered the wrong passcode more than the maximum number of allowed retries. To fix this you should remove user data and call -reset on this vault.");
    !completion ?: completion(nil);
    return;
  }
  
  SPXAssertTrueOrPerformAction(!__semaphore, SPXLog(@"There is another authentication still in progress..."));
  
  self.completionBlock = completion;
  
  if (policy == SPXSecurePolicyNone) {
    completion([SPXSecureOnceSession new]);
    return;
  }
  
  if (policy == SPXSecurePolicyConfirmationOnly) {
    NSString *title = description ? [NSString stringWithFormat:@"Are you sure you want to %@?", description] : @"Are you sure?";
    
    if ([NSThread isMainThread]) {
      [self authenticateOnMainThreadWithConfirmationTitle:title description:description];
    } else {
      [self authenticateOnBackgroundThreadWithConfirmationTitle:title description:description];
    }
    
    return;
  }
  
  SPXAssertTrueOrReturn(credential || self.passcodeViewControllerClass);
  
  if (credential) {
    !self.completionBlock ?: self.completionBlock([self sessionForPolicy:policy credential:credential]);
    return;
  }
  
  if (!self.passcodeViewControllerClass) {
    SPXLog(@"Could not authenticate because no credential was provided and no passcodeViewController was registered");
    !self.completionBlock ?: self.completionBlock(nil);
    return;
  }
  
  if (policy == SPXSecurePolicyTimedSessionWithPIN && self.timedSession.isValid) {
    !self.completionBlock ?: self.completionBlock(self.timedSession);
    return;
  }
  
  if ([NSThread isMainThread]) {
    [self authenticateOnMainThreadWithPolicy:policy credential:credential completion:completion];
  } else {
    [self authenticateOnBackgroundThreadWithPolicy:policy credential:credential completion:completion];
  }
}

- (void)authenticateOnBackgroundThreadWithPolicy:(SPXSecurePolicy)policy credential:(id<SPXSecureCredential>)credential completion:(void (^)(id<SPXSecureSession>))completion
{
  __weak typeof(self) weakInstance = self;
  __block id <SPXSecureSession> session = nil;

  __semaphore = dispatch_semaphore_create(0);
  dispatch_sync(dispatch_get_main_queue(), ^{
    id <SPXSecurePasscodeViewController> controller = [weakInstance presentPasscodeViewController];
    SPXSecurePasscodeViewControllerState state = (weakInstance.credential) ? SPXSecurePasscodeViewControllerStateAuthenticating : SPXSecurePasscodeViewControllerStateInitializing;
    
    [controller transitionToState:state animated:YES completion:^id<SPXSecureSession>(id<SPXSecureCredential> credential) {
      if (!credential) {
        session = nil;
        spx_kill_semaphore();
        return nil;
      }
      
      session = [weakInstance sessionForPolicy:policy credential:credential];
      
      if (session) {
        spx_kill_semaphore();
      }
      
      return session;
    }];
  });
  
  dispatch_semaphore_wait(__semaphore, DISPATCH_TIME_FOREVER);
  
  !self.completionBlock ?: self.completionBlock(session);
}

- (void)authenticateOnMainThreadWithPolicy:(SPXSecurePolicy)policy credential:(id<SPXSecureCredential>)credential completion:(void (^)(id<SPXSecureSession>))completion
{
  __weak typeof(self) weakInstance = self;
  __block id <SPXSecureSession> session = nil;
  __semaphore = dispatch_semaphore_create(0);
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    dispatch_async(dispatch_get_main_queue(), ^{
      id <SPXSecurePasscodeViewController> controller = [weakInstance presentPasscodeViewController];
      SPXSecurePasscodeViewControllerState state = (weakInstance.credential) ? SPXSecurePasscodeViewControllerStateAuthenticating : SPXSecurePasscodeViewControllerStateInitializing;
      
      [controller transitionToState:state animated:YES completion:^id<SPXSecureSession>(id<SPXSecureCredential> credential) {
        if (!credential) {
          session = nil;
          spx_kill_semaphore();
          return nil;
        }
        
        session = [weakInstance sessionForPolicy:policy credential:credential];
        
        if (session) {
          spx_kill_semaphore();
        }
        
        return session;
      }];
    });
    
    dispatch_semaphore_wait(__semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_async(dispatch_get_main_queue(), ^{
      !self.completionBlock ?: self.completionBlock(session);
    });
  });
}

- (void)authenticateOnMainThreadWithConfirmationTitle:(NSString *)title description:(NSString *)description
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:description ?: @"Continue" otherButtonTitles:nil] showInView:[UIApplication sharedApplication].keyWindow];
    });
    
    dispatch_semaphore_wait(__semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_async(dispatch_get_main_queue(), ^{
      !self.completionBlock ?: self.completionBlock(self.success ? [SPXSecureOnceSession session] : nil);
    });
  });
}

- (void)authenticateOnBackgroundThreadWithConfirmationTitle:(NSString *)title description:(NSString *)description
{
  __semaphore = dispatch_semaphore_create(0);
  
  dispatch_sync(dispatch_get_main_queue(), ^{
    [[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:description ?: @"Continue" otherButtonTitles:nil] showInView:[UIApplication sharedApplication].keyWindow];
  });
  
  dispatch_semaphore_wait(__semaphore, DISPATCH_TIME_FOREVER);
  
  !self.completionBlock ?: self.completionBlock(self.success ? [SPXSecureOnceSession session] : nil);
}

- (id <SPXSecurePasscodeViewController>)presentPasscodeViewController
{
  id <SPXSecurePasscodeViewController> controller = [self.passcodeViewControllerClass.class new];
  SPXAssertTrueOrReturnNil([controller respondsToSelector:@selector(transitionToState:animated:completion:)]);
  UIViewController *viewController = (UIViewController *)controller;
  
  viewController.modalPresentationStyle = UIModalPresentationFullScreen;
  viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  
  UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
  [presentingController presentViewController:viewController animated:YES completion:nil];
  
  return controller;
}

- (id <SPXSecureSession>)sessionForPolicy:(SPXSecurePolicy)policy credential:(id <SPXSecureCredential>)credential
{
  if (!self.credential) {
    self.credential = credential;
  }
  
  if (![credential isEqualToCredential:self.credential]) {
    if (self.maximumRetryCount) {
      if (self.currentRetryCount < self.maximumRetryCount) {
        [self incrementRetryCount];
      } else {
        [self lock];
      }
    }
    
    return nil;
  }
  
  [self resetCurrentRetryCount];
  
  if (policy == SPXSecurePolicyTimedSessionWithPIN) {
    if (!self.timedSession.isValid) {
      self.timedSession = [SPXSecureTimedSession sessionWithTimeoutInterval:self.defaultTimeoutInterval];
    }
    
    return self.timedSession;
  }
  
  return [SPXSecureOnceSession session];
}

- (NSUInteger)currentRetryCount
{
  SPXKeychain *keychain = [SPXKeychain sharedInstance];
  NSString *key = [self persistentKeyForSelector:@selector(currentRetryCount)];
  return [keychain[key] unsignedIntegerValue];
}

- (void)setCurrentRetryCount:(NSUInteger)currentRetryCount
{
  SPXKeychain *keychain = [SPXKeychain sharedInstance];
  NSString *key = [self persistentKeyForSelector:@selector(currentRetryCount)];
  keychain[key] = @(currentRetryCount);
}

- (void)incrementRetryCount
{
  self.currentRetryCount++;
}

- (void)resetCurrentRetryCount
{
  self.currentRetryCount = 0;
}

- (id<SPXSecureCredential>)credential
{
  SPXKeychain *keychain = [SPXKeychain sharedInstance];
  NSString *key = [self persistentKeyForSelector:@selector(credential)];
  return keychain[key];
}

- (void)setCredential:(id<SPXSecureCredential>)credential
{
  SPXKeychain *keychain = [SPXKeychain sharedInstance];
  NSString *key = [self persistentKeyForSelector:@selector(credential)];
  keychain[key] = credential;
}

- (void)reset
{
  self.credential = nil;
  
  SPXKeychain *keychain = [SPXKeychain sharedInstance];
  NSString *key = [self persistentKeyForSelector:@selector(lock)];
  keychain[key] = nil;
}

- (void)resetPasscode
{
  if (!self.hasCredential) {
    SPXLog(@"Nothing reset. This vault doesnt have an existing credential to reset.");
    return;
  }
  
  __weak typeof(self) weakInstance = self;
  [self authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN completion:^(id<SPXSecureSession> session) {
    if (session.isValid) {
      weakInstance.credential = nil;
      [weakInstance resetCurrentRetryCount];
    }
  }];
}

- (BOOL)isLocked
{
  SPXKeychain *keychain = [SPXKeychain sharedInstance];
  NSString *key = [self persistentKeyForSelector:@selector(lock)];
  return [keychain[key] boolValue];
}

- (void)lock
{
  SPXKeychain *keychain = [SPXKeychain sharedInstance];
  NSString *key = [self persistentKeyForSelector:@selector(lock)];
  keychain[key] = @YES;
  
  [self resetCurrentRetryCount];
  // we set the credential to something random so it can't even be guessed. Just an additional level of security
  self.credential = [SPXSecurePasscodeCredential credentialWithPasscode:[NSUUID UUID].UUIDString];
  
  SPXLog(@"The vault was locked because the maximum number of retries was reached!");
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
  // HACKY -- REPLACE!!
  self.success = NO;
  
  if (!buttonIndex) {
    self.success = YES;
  }
  
  spx_kill_semaphore();
}

@end
