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

@import LocalAuthentication;

#import "SPXSecureVault.h"
#import "SPXSecureSession.h"
#import "SPXDefines.h"
#import "SPXKeychain.h"

NSString *const SPXSecureVaultDidFailAuthenticationPermanently = @"SPXSecureVaultDidFailAuthenticationPermanently";

static NSMutableDictionary *__vaults;
static dispatch_semaphore_t __semaphore;

static inline void spx_kill_semaphore() {
  dispatch_semaphore_signal(__semaphore);
}

@interface SPXSecureVault () <UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) id <SPXSecureCredential> credential;
@property (nonatomic, strong) SPXSecureTimedSession *timedSession;

@property (nonatomic, assign) Class <SPXSecurePasscodeViewController> passcodeViewControllerClass;
@property (nonatomic, assign) Class vaultSettingsViewControllerClass;
@property (nonatomic, assign) Class eventsViewControllerClass;

@property (nonatomic, copy) void (^completionBlock)(id <SPXSecureSession> session);
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL confirmationWasSuccessful;
@property (nonatomic, assign) NSUInteger currentRetryCount;

@end

@implementation SPXSecureVault

- (void)dealloc
{
  spx_kill_semaphore();
  [self.timedSession invalidate];
  self.credential = nil;
}

#pragma mark - Initializers

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

#pragma mark - ViewController Registration

- (void)registerPasscodeViewControllerClass:(Class<SPXSecurePasscodeViewController>)viewControllerClass
{
  self.passcodeViewControllerClass = viewControllerClass;
}

- (void)registerVaultSettingsViewControllerClass:(Class)viewControllerClass
{
  self.vaultSettingsViewControllerClass = viewControllerClass;
}

- (void)registerEventsViewControllerClass:(Class)viewControllerClass
{
  self.eventsViewControllerClass = viewControllerClass;
}

#pragma mark - ViewControllers

- (UIViewController *)eventsViewController
{
  UIViewController *eventsController = [self.eventsViewControllerClass.class new];
  return [[UINavigationController alloc] initWithRootViewController:eventsController];
}

- (UIViewController *)settingsViewController
{
  UIViewController *eventsController = [self.vaultSettingsViewControllerClass.class new];
  return [[UINavigationController alloc] initWithRootViewController:eventsController];
}

#pragma mark - Updating Passcode

- (void)updateCredentialWithCompletion:(SPXSecureVaultCompletionBlock)completion
{
  [self updateCredentialWithExistingCredential:self.credential newCredential:nil completion:completion];
}

- (void)updateCredentialWithExistingCredential:(id<SPXSecureCredential>)existingCredential newCredential:(id<SPXSecureCredential>)newCredential completion:(SPXSecureVaultCompletionBlock)completion
{
  if ([self isLocked]) {
    SPXLog(@"Unabled to update the credential. The vault has been locked.");
    !completion ?: completion(NO);
    return;
  }
  
  __weak typeof(self) weakInstance = self;
  id <SPXSecureCredential> credential = self.credential;
  
  void(^promptForNewCredential)() = ^() {
    [weakInstance authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN updating:NO completion:^(id<SPXSecureSession> session) {
      BOOL isValid = session.isValid;
      !completion ?: completion(isValid);
      
      if (!isValid) {
        weakInstance.credential = credential;
      }
    }];
  };
  
  if (!self.credential && newCredential) {
    self.credential = newCredential;
    !completion ?: completion(YES);
    return;
  }
  
  if (!self.credential && !newCredential) {
    promptForNewCredential();
    return;
  }
  
  if (![self.credential isEqualToCredential:existingCredential]) {
    !completion ?: completion(NO);
    return;
  }
  
  if ([self.credential isEqualToCredential:existingCredential] && newCredential) {
    self.credential = newCredential;
    !completion ?: completion(YES);
    return;
  }
  
  [self authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN updating:YES completion:^(id<SPXSecureSession> session) {
    if (session.isValid) {
      weakInstance.credential = nil;
      promptForNewCredential();
    } else {
      weakInstance.credential = credential;
      !completion ?: completion(NO);
    }
  }];
}

#pragma mark - Authentication

- (void)authenticateWithPolicy:(SPXSecurePolicy)policy description:(NSString *)description completion:(SPXSecureVaultAuthenticationCompletionBlock)completion
{
  [self authenticateWithPolicy:policy description:description credential:nil completion:completion];
}

- (void)authenticateWithPolicy:(SPXSecurePolicy)policy description:(NSString *)description credential:(id<SPXSecureCredential>)credential completion:(SPXSecureVaultAuthenticationCompletionBlock)completion
{
  if (policy == SPXSecurePolicyNone) {
    !completion ?: completion([SPXSecureOnceSession session]);
    return;
  }
  
  if (policy == SPXSecurePolicyConfirmationOnly) {
    [self authenticateWithConfirmation:description completion:completion];
    return;
  }
  
  if ([self isLocked]) {
    SPXLog(@"The vault is current locked!");
    if ([self.delegate respondsToSelector:@selector(vault:didFailAuthenticationWithRemainingRetryCount:)]) {
      [self.delegate vault:self didFailAuthenticationWithRemainingRetryCount:self.remainingRetryCount];
    }
    
    !completion ?: completion(nil);
    return;
  }
  
  if ((self.fallbackToConfirmation && !self.passcodeViewControllerClass) || (self.fallbackToConfirmation && !self.credential)) {
    [self authenticateWithConfirmation:description completion:completion];
    return;
  }
  
  if (credential) {
    !completion ?: completion([self sessionForPolicy:policy credential:credential]);
    return;
  }
  
  if (policy == SPXSecurePolicyTimedSessionWithPIN && self.timedSession.isValid) {
    !completion ?: completion(self.timedSession);
    return;
  }
  
  if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 && self.hasCredential) {
    LAContext *context = [LAContext new];
    [self authenticateWithContext:context policy:policy description:description completion:completion];
    return;
  }
  
  [self authenticateWithPolicy:policy updating:NO completion:completion];
}

- (void)authenticateWithPolicy:(SPXSecurePolicy)policy updating:(BOOL)updating completion:(SPXSecureVaultAuthenticationCompletionBlock)completion
{
  __weak typeof(self) weakInstance = self;
  __block id<SPXSecureSession> session = nil;
  self.completionBlock = completion;
  
  [self presentWithPresentationBlock:^{
    UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController <SPXSecurePasscodeViewController> *controller = (UIViewController <SPXSecurePasscodeViewController>*)presentingController.presentedViewController;
    
    while (controller && ![controller conformsToProtocol:@protocol(SPXSecurePasscodeViewController)]) {
      if (presentingController.presentedViewController) {
        presentingController = presentingController.presentedViewController;
      }
      
      controller = (UIViewController <SPXSecurePasscodeViewController>*)controller.presentedViewController;
    }
    
    if (!controller) {
      controller = [self.passcodeViewControllerClass.class new];
      [weakInstance.passcodeViewControllerClass.class new];
      UIViewController *viewController = (UIViewController *)controller;
      viewController.modalPresentationStyle = UIModalPresentationFullScreen;
      viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
      [presentingController presentViewController:viewController animated:YES completion:nil];
    }
    
    SPXCAssertTrueOrReturn([controller respondsToSelector:@selector(transitionToState:animated:completion:)]);
    SPXSecurePasscodeViewControllerState state = (weakInstance.credential) ? SPXSecurePasscodeViewControllerStateAuthenticating : SPXSecurePasscodeViewControllerStateInitializing;
    state = updating ? SPXSecurePasscodeViewControllerStateUpdating : state;
    
    [controller transitionToState:state animated:YES completion:^id<SPXSecureSession>(id<SPXSecureCredential> credential) {
      if (credential) {
        session = [weakInstance sessionForPolicy:policy credential:credential];
      }
      
      if (session || !credential) {
        spx_kill_semaphore();
      }
      
      return session;
    }];
  } completion:^{
    !weakInstance.completionBlock ?: weakInstance.completionBlock(session);
  }];
}

- (void)authenticateWithConfirmation:(NSString *)description completion:(SPXSecureVaultAuthenticationCompletionBlock)completion
{
  __weak typeof(self) weakInstance = self;
  self.completionBlock = completion;
  
  [self presentWithPresentationBlock:^{
    NSString *title = @"Are you sure you want to perform this action?";
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || weakInstance.useAlertViewForConfirmation) {
      [[[UIAlertView alloc] initWithTitle:description message:title delegate:weakInstance cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil] show];
      return;
    }
    
    UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [[[UIActionSheet alloc] initWithTitle:title delegate:weakInstance cancelButtonTitle:@"Cancel" destructiveButtonTitle:description ?: @"Continue" otherButtonTitles:nil] showInView:view];
  } completion:^{
    !weakInstance.completionBlock ?: weakInstance.completionBlock([weakInstance sessionForPolicy:SPXSecurePolicyConfirmationOnly credential:nil]);
  }];
}

- (void)authenticateWithContext:(LAContext *)context policy:(SPXSecurePolicy)policy description:(NSString *)description completion:(SPXSecureVaultAuthenticationCompletionBlock)completion
{
  description = description ?: @"Authenticating";
  
  __weak typeof(self) weakInstance = self;
  __block NSInteger errorCode = 0;
  self.completionBlock = completion;
  
  [self presentWithPresentationBlock:^{
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:description reply:^(BOOL success, NSError *error) {
      switch (error.code) {
        case kLAErrorUserCancel:
          errorCode = kLAErrorUserCancel;
          break;
        case kLAErrorAuthenticationFailed:
          errorCode = kLAErrorAuthenticationFailed;
          break;
        default:
          errorCode = success ? 0 : kLAErrorUserFallback;
          break;
      }
      
      spx_kill_semaphore();
    }];
  } completion:^{
    if (errorCode == kLAErrorUserCancel) {
      !weakInstance.completionBlock ?: weakInstance.completionBlock(nil);
      return;
    }
    
    if (errorCode == kLAErrorUserFallback) {
      [self authenticateWithPolicy:policy updating:NO completion:weakInstance.completionBlock];
      return;
    }
    
    id <SPXSecureCredential> credential = !errorCode ? weakInstance.credential : nil;
    id <SPXSecureSession> session = [weakInstance sessionForPolicy:policy credential:credential];
    !weakInstance.completionBlock ?: weakInstance.completionBlock(session);
  }];
}

#pragma mark - Presentation

- (void)presentWithPresentationBlock:(void (^)())presentation completion:(void (^)())completion
{
  if ([NSThread isMainThread]) {
    [self presentOnMainThread:presentation completion:completion];
  } else {
    [self presentOnBackgroundThread:presentation completion:completion];
  }
}

- (void)presentOnMainThread:(void (^)())presentation completion:(void (^)())completion
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    __semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
      presentation();
    });
    
    dispatch_semaphore_wait(__semaphore, DISPATCH_TIME_FOREVER);  
    
    dispatch_async(dispatch_get_main_queue(), ^{
      !completion ?: completion();
    });
  });
}

- (void)presentOnBackgroundThread:(void (^)())presentationBlock completion:(void (^)())completion
{
  __semaphore = dispatch_semaphore_create(0);
  
  dispatch_sync(dispatch_get_main_queue(), ^{
    presentationBlock();
  });
  
  dispatch_semaphore_wait(__semaphore, DISPATCH_TIME_FOREVER);
  
  !completion ?: completion();
}

#pragma mark - UIKit Delegates

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
  self.confirmationWasSuccessful = (!buttonIndex);
  spx_kill_semaphore();
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
  self.confirmationWasSuccessful = (buttonIndex);
  spx_kill_semaphore();
}

#pragma mark - Session

- (id <SPXSecureSession>)sessionForPolicy:(SPXSecurePolicy)policy credential:(id <SPXSecureCredential>)credential
{
  if (!self.credential) {
    self.credential = credential;
  }
  
  if (policy == SPXSecurePolicyConfirmationOnly) {
    return self.confirmationWasSuccessful ? [SPXSecureOnceSession session] : nil;
  }
  
  if (![credential isEqualToCredential:self.credential]) {
    if (self.maximumRetryCount) {
      if (self.currentRetryCount >= self.maximumRetryCount - 1) {
        [self lock];
      } else {
        self.currentRetryCount++;
      }
    }
    
    return nil;
  }
  
  self.currentRetryCount = 0;
  
  if (policy == SPXSecurePolicyTimedSessionWithPIN) {
    self.timedSession = [SPXSecureTimedSession sessionWithTimeoutInterval:self.defaultTimeoutInterval];
    return self.timedSession;
  }
  
  return [SPXSecureOnceSession session];
}

#pragma mark - Resets

- (void)removeCredentialWithCompletion:(SPXSecureVaultCompletionBlock)completion
{
  if ([self isLocked]) {
    SPXLog(@"Nothing to reset. The vault has been locked.");
    !completion ?: completion(NO);
    return;
  }
  
  if (!self.hasCredential) {
    SPXLog(@"Nothing to reset. This vault does not have an existing credential to reset.");
    return;
  }
  
  __weak typeof(self) weakInstance = self;
  [self authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN updating:NO completion:^(id <SPXSecureSession> session) {
    if (session) {
      weakInstance.credential = nil;
      [weakInstance.timedSession invalidate];
      weakInstance.timedSession = nil;
      weakInstance.currentRetryCount = 0;
    }
    
    !completion ?: completion(session.isValid);
  }];
}

- (void)resetVault
{
  [self.timedSession invalidate];
  self.timedSession = nil;
  
  self.credential = nil;
  self.currentRetryCount = 0;
  
  [self setObject:@NO forSelector:@selector(lock)];
}

#pragma mark - Keychain Values

- (BOOL)isLocked
{
  return [[self objectForSelector:@selector(lock)] boolValue];
}

- (void)lock
{
  [self setObject:@YES forSelector:@selector(lock)];
  self.currentRetryCount = 0;
  SPXLog(@"The vault was locked because the maximum number of retries was reached!");
  [[NSNotificationCenter defaultCenter] postNotificationName:SPXSecureVaultDidFailAuthenticationPermanently object:self];
  
  if ([self.delegate respondsToSelector:@selector(vaultDidLock:)]) {
    [self.delegate vaultDidLock:self];
  }
}

- (BOOL)hasCredential
{
  return (self.credential != nil);
}

- (NSUInteger)currentRetryCount
{
  return [[self objectForSelector:@selector(currentRetryCount)] unsignedIntegerValue];
}

- (void)setCurrentRetryCount:(NSUInteger)currentRetryCount
{
  [self setObject:@(currentRetryCount) forSelector:@selector(currentRetryCount)];
  
  if (currentRetryCount) {
    if ([self.delegate respondsToSelector:@selector(vault:didFailAuthenticationWithRemainingRetryCount:)]) {
      [self.delegate vault:self didFailAuthenticationWithRemainingRetryCount:self.remainingRetryCount];
    }
  }
}

- (void)setMaximumRetryCount:(NSUInteger)maximumRetryCount
{
  [self setObject:@(maximumRetryCount) forSelector:@selector(maximumRetryCount)];
}

- (void)setDefaultTimeoutInterval:(NSTimeInterval)defaultTimeoutInterval
{
  [self setObject:@(MAX(defaultTimeoutInterval, 0)) forSelector:@selector(defaultTimeoutInterval)];
  [self.timedSession invalidate];
}

- (NSUInteger)maximumRetryCount
{
  NSNumber *interval = [self objectForSelector:@selector(maximumRetryCount)];
  
  if (!interval) {
    return 5;
  }
  
  return [[self objectForSelector:@selector(maximumRetryCount)] unsignedIntegerValue];
}

- (NSUInteger)remainingRetryCount
{
  return self.maximumRetryCount - self.currentRetryCount;
}

- (NSTimeInterval)defaultTimeoutInterval
{
  NSNumber *interval = [self objectForSelector:@selector(defaultTimeoutInterval)];
  
  if (!interval) {
    return 60;
  }
  
  return [[self objectForSelector:@selector(defaultTimeoutInterval)] doubleValue];
}

- (id<SPXSecureCredential>)credential
{
  return [self objectForSelector:@selector(credential)];
}

- (void)setCredential:(id<SPXSecureCredential>)credential
{
  [self setObject:credential forSelector:@selector(credential)];
}

#pragma mark - Keychain Helper

- (NSString *)persistentKeyForSelector:(SEL)selector
{
  NSString *name = [@"Abracadabra" stringByAppendingPathExtension:self.name];
  return [name stringByAppendingPathExtension:NSStringFromSelector(selector)];
}

- (void)setObject:(id)object forSelector:(SEL)selector
{
  SPXKeychain *keychain = [SPXKeychain sharedInstance];
  NSString *key = [self persistentKeyForSelector:selector];
  keychain[key] = object;
}

- (id)objectForSelector:(SEL)selector
{
  SPXKeychain *keychain = [SPXKeychain sharedInstance];
  NSString *key = [self persistentKeyForSelector:selector];
  return keychain[key];
}

@end
