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

@interface SPXSecureVault ()

@property (nonatomic, strong) id <SPXSecureCredential> credential;
@property (nonatomic, strong) SPXSecureTimedSession *timedSession;
@property (nonatomic, strong) SPXSecureAppSession *appSession;
@property (nonatomic, assign) BOOL unlocked;

@property (nonatomic, assign) Class <SPXSecurePasscodeViewController> passcodeViewControllerClass;
@property (nonatomic, strong) id <SPXSecurePasscodeViewController> passCodeViewController;
@property (nonatomic, assign) Class vaultSettingsViewControllerClass;
@property (nonatomic, assign) Class eventsViewControllerClass;

@property (nonatomic, copy) void (^completionBlock)(id <SPXSecureSession> session, id <SPXSecurePasscodeViewController> controller);
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL confirmationWasSuccessful;
@property (nonatomic, assign) NSUInteger currentRetryCount;
@property (nonatomic, strong)  dispatch_semaphore_t semaphore;

@end

@implementation SPXSecureVault

- (void)dealloc
{
  dispatch_semaphore_signal(self.semaphore);
  self.credential = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (SPXSecurePresentationConfiguration *)presentationConfiguration
{
  return _presentationConfiguration ?: (_presentationConfiguration = [SPXSecurePresentationConfiguration new]);
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

- (instancetype)init
{
  self = [super init];
  SPXAssertTrueOrReturnNil(self);
  
  __weak typeof(self) weakInstance = self;
  [[NSNotificationCenter defaultCenter] addObserver:weakInstance selector:@selector(applicationWillEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:weakInstance selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
  return self;
}

- (BOOL)isUnlocked
{
  return self.appSession.isValid;
}

- (void)applicationWillEnterForeground:(NSNotification *)note
{
  if (!self.timedSession.isValid) {
    [self.appSession invalidate];
  }
}

- (void)applicationWillEnterBackground:(NSNotification *)note
{
  if (self.appSession.isValid) {
    self.timedSession = [SPXSecureTimedSession sessionWithTimeoutInterval:self.defaultTimeoutInterval];
  }
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

- (void)updateCredentialWithConfiguration:(SPXSecurePresentationConfiguration *)configuration completion:(SPXSecureVaultCompletionBlock)completion
{
  [self updateCredentialWithExistingCredential:self.credential newCredential:nil configuration:configuration completion:completion];
}

- (void)updateCredentialWithExistingCredential:(id<SPXSecureCredential>)existingCredential newCredential:(id<SPXSecureCredential>)newCredential configuration:(SPXSecurePresentationConfiguration *)configuration completion:(SPXSecureVaultCompletionBlock)completion
{
  SPXSecurePresentationConfiguration *config = configuration ?: self.presentationConfiguration;
  
  if ([self isLocked]) {
    SPXLog(@"Unabled to update the credential. The vault has been locked.");
    !completion ?: completion(NO, self.passCodeViewController);
    return;
  }
  
  __weak typeof(self) weakInstance = self;
  id <SPXSecureCredential> credential = self.credential;
  
  void(^promptForNewCredential)() = ^() {
    [weakInstance authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN updating:NO configuration:config completion:^(id<SPXSecureSession> session, id <SPXSecurePasscodeViewController> controller) {
      BOOL isValid = session.isValid;
      !completion ?: completion(isValid, self.passCodeViewController);
      
      if (!isValid) {
        weakInstance.credential = credential;
      }
    }];
  };
  
  if (!self.credential && newCredential) {
    self.credential = newCredential;
    !completion ?: completion(YES, self.passCodeViewController);
    return;
  }
  
  if (!self.credential && !newCredential) {
    promptForNewCredential();
    return;
  }
  
  if (![self.credential isEqualToCredential:existingCredential]) {
    !completion ?: completion(NO, self.passCodeViewController);
    return;
  }
  
  if ([self.credential isEqualToCredential:existingCredential] && newCredential) {
    self.credential = newCredential;
    !completion ?: completion(YES, self.passCodeViewController);
    return;
  }
  
  [self authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN updating:YES configuration:config completion:^(id<SPXSecureSession> session, id <SPXSecurePasscodeViewController> controller) {
    if (session.isValid) {
      weakInstance.credential = nil;
      promptForNewCredential();
    } else {
      weakInstance.credential = credential;
      !completion ?: completion(NO, self.passCodeViewController);
    }
  }];
}

#pragma mark - Authentication

- (id <SPXSecureSession>)authenticateWithPolicy:(SPXSecurePolicy)policy session:(id <SPXSecureSession>)session
{
  return [self sessionForPolicy:policy credential:self.credential];
}

- (void)authenticateWithPolicy:(SPXSecurePolicy)policy description:(NSString *)description configuration:(SPXSecurePresentationConfiguration *)configuration completion:(SPXSecureVaultAuthenticationCompletionBlock)completion
{
  [self authenticateWithPolicy:policy description:description credential:nil configuration:configuration completion:completion];
}

- (void)authenticateWithPolicy:(SPXSecurePolicy)policy description:(NSString *)description credential:(id<SPXSecureCredential>)credential configuration:(SPXSecurePresentationConfiguration *)configuration completion:(SPXSecureVaultAuthenticationCompletionBlock)completion
{
  SPXSecurePresentationConfiguration *config = configuration ?: self.presentationConfiguration;

  if (policy == SPXSecurePolicyNone) {
    !completion ?: completion([SPXSecureOnceSession session], self.passCodeViewController);
    return;
  }
  
  if (policy == SPXSecurePolicyConfirmationOnly) {
    [self authenticateWithConfirmation:description configuration:config completion:completion];
    return;
  }
  
  if ([self isLocked]) {
    SPXLog(@"The vault is current locked!");
    if ([self.delegate respondsToSelector:@selector(vault:didFailAuthenticationWithRemainingRetryCount:)]) {
      [self.delegate vault:self didFailAuthenticationWithRemainingRetryCount:self.remainingRetryCount];
    }
    
    !completion ?: completion(nil, self.passCodeViewController);
    return;
  }
  
  if ((config.fallbackToConfirmation && !self.passcodeViewControllerClass) || (config.fallbackToConfirmation && !self.credential)) {
    [self authenticateWithConfirmation:description configuration:config completion:completion];
    return;
  }
  
  if (credential) {
    !completion ?: completion([self sessionForPolicy:policy credential:credential], self.passCodeViewController);
    return;
  }
  
  if (policy == SPXSecurePolicyTimedSessionWithPIN && self.timedSession.isValid) {
    !completion ?: completion(self.timedSession, self.passCodeViewController);
    return;
  }
  
  if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1 && self.hasCredential) {
    LAContext *context = [LAContext new];
    [self authenticateWithContext:context policy:policy description:description configuration:config completion:completion];
    return;
  }
  
  [self authenticateWithPolicy:policy updating:NO configuration:config completion:completion];
}

- (void)authenticateWithPolicy:(SPXSecurePolicy)policy updating:(BOOL)updating configuration:(SPXSecurePresentationConfiguration *)configuration completion:(SPXSecureVaultAuthenticationCompletionBlock)completion
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
      weakInstance.passCodeViewController = controller;
      controller.presentationConfiguration = configuration;
      
      if (configuration.preferredPresentationMode == SPXSecurePresentationModeNavigation && (presentingController.navigationController || [presentingController isKindOfClass:[UINavigationController class]])) {
        UINavigationController *navController = nil;
        if (presentingController.navigationController) {
          navController = (UINavigationController *)presentingController.navigationController;
        } else {
          navController = (UINavigationController *)presentingController;
        }
        
        [navController pushViewController:controller animated:configuration.presentWithAnimation];
      } else {
        UIViewController *viewController = (UIViewController *)controller;
        viewController.modalPresentationStyle = UIModalPresentationFullScreen;
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [presentingController presentViewController:viewController animated:configuration.presentWithAnimation completion:nil];
      }
    }
    
    SPXCAssertTrueOrReturn([controller respondsToSelector:@selector(transitionToState:animated:completion:)]);
    SPXSecurePasscodeViewControllerState state = (weakInstance.hasCredential) ? SPXSecurePasscodeViewControllerStateAuthenticating : SPXSecurePasscodeViewControllerStateInitializing;
    state = updating ? SPXSecurePasscodeViewControllerStateUpdating : state;
    
    [controller transitionToState:state animated:YES completion:^id<SPXSecureSession>(id<SPXSecureCredential> credential) {
      if (credential) {
        session = [weakInstance sessionForPolicy:policy credential:credential];
      }
      
      if (session || !credential) {
        dispatch_semaphore_signal(self.semaphore);
      }
      
      return session;
    }];
  } completion:^{
    !weakInstance.completionBlock ?: weakInstance.completionBlock(session, self.passCodeViewController);
  }];
}

- (void)authenticateWithConfirmation:(NSString *)description configuration:(SPXSecurePresentationConfiguration *)configuration completion:(SPXSecureVaultAuthenticationCompletionBlock)completion
{
  __weak typeof(self) weakInstance = self;
  self.completionBlock = completion;
  
  [self presentWithPresentationBlock:^{
    NSString *title = @"Are you sure you want to perform this action?";
    
    BOOL useAlertView = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || self.presentationConfiguration.useAlertViewForConfirmation;
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:useAlertView ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [controller addAction:[UIAlertAction actionWithTitle:description style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
      self.confirmationWasSuccessful = YES;
      dispatch_semaphore_signal(self.semaphore);
    }]];
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:controller animated:YES completion:nil];
  } completion:^{
    !weakInstance.completionBlock ?: weakInstance.completionBlock([weakInstance sessionForPolicy:SPXSecurePolicyConfirmationOnly credential:nil], self.passCodeViewController);
  }];
}

- (void)authenticateWithContext:(LAContext *)context policy:(SPXSecurePolicy)policy description:(NSString *)description configuration:(SPXSecurePresentationConfiguration *)configuration completion:(SPXSecureVaultAuthenticationCompletionBlock)completion
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
      
      dispatch_semaphore_signal(self.semaphore);
    }];
  } completion:^{
    if (errorCode == kLAErrorUserCancel) {
      !weakInstance.completionBlock ?: weakInstance.completionBlock(nil, self.passCodeViewController);
      return;
    }
    
    if (errorCode == kLAErrorUserFallback) {
      [self authenticateWithPolicy:policy updating:NO configuration:configuration completion:weakInstance.completionBlock];
      return;
    }
    
    id <SPXSecureCredential> credential = !errorCode ? weakInstance.credential : nil;
    id <SPXSecureSession> session = [weakInstance sessionForPolicy:policy credential:credential];
    !weakInstance.completionBlock ?: weakInstance.completionBlock(session, self.passCodeViewController);
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
    self.semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(dispatch_get_main_queue(), ^{
      presentation();
    });
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_async(dispatch_get_main_queue(), ^{
      !completion ?: completion();
    });
  });
}

- (void)presentOnBackgroundThread:(void (^)())presentationBlock completion:(void (^)())completion
{
  self.semaphore = dispatch_semaphore_create(0);
  
  dispatch_sync(dispatch_get_main_queue(), ^{
    presentationBlock();
  });
  
  dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
  
  !completion ?: completion();
}

#pragma mark - UIKit Delegates

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
  self.confirmationWasSuccessful = (!buttonIndex);
  dispatch_semaphore_signal(self.semaphore);
}

#pragma mark - Session

- (id <SPXSecureSession>)sessionForPolicy:(SPXSecurePolicy)policy credential:(id <SPXSecureCredential>)credential
{
  if (!self.credential && credential) {
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
  
  if (policy == SPXSecurePolicyApplication) {
    self.appSession = [SPXSecureAppSession session];
    return self.appSession;
  }
  
  if (policy == SPXSecurePolicyTimedSessionWithPIN) {
    return [SPXSecureTimedSession sessionWithTimeoutInterval:self.defaultTimeoutInterval];
  }
  
  return [SPXSecureOnceSession session];
}

#pragma mark - Resets

- (void)removeCredentialWithConfiguration:(SPXSecurePresentationConfiguration *)configuration completion:(SPXSecureVaultCompletionBlock)completion
{
  if ([self isLocked]) {
    SPXLog(@"Nothing to reset. The vault has been locked.");
    !completion ?: completion(NO, self.passCodeViewController);
    return;
  }
  
  if (!self.hasCredential) {
    SPXLog(@"Nothing to reset. This vault does not have an existing credential to reset.");
    return;
  }
  
  __weak typeof(self) weakInstance = self;
  SPXSecurePresentationConfiguration *config = configuration ?: self.presentationConfiguration;
  [self authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN updating:NO configuration:config completion:^(id <SPXSecureSession> session, id <SPXSecurePasscodeViewController> controller) {
    if (session) {
      weakInstance.credential = nil;
      [weakInstance.timedSession invalidate];
      weakInstance.timedSession = nil;
      weakInstance.currentRetryCount = 0;
    }
    
    !completion ?: completion(session.isValid, self.passCodeViewController);
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
