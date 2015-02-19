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
#import "SPXDispatch.h"

NSString *const SPXSecureVaultDidFailAuthenticationPermanently = @"SPXSecureVaultDidFailAuthenticationPermanently";

@interface SPXSecureVault () <UIActionSheetDelegate>

@property (nonatomic, strong) id <SPXSecureCredential> credential;
@property (nonatomic, strong) SPXSecureTimedSession *timedSession;
@property (nonatomic, assign) Class <SPXSecurePasscodeViewController> passcodeViewControllerClass;
@property (nonatomic, assign) Class vaultSettingsViewControllerClass;
@property (nonatomic, copy) void (^completionBlock)(id <SPXSecureSession> session);

@end

@implementation SPXSecureVault

+ (instancetype)defaultVault
{
  static SPXSecureVault *_sharedInstance = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (instancetype)init
{
  self = [super init];
  SPXAssertTrueOrReturnNil(self);
  _maximumRetryCount = 10;
  _defaultTimeoutInterval = 60;
  return self;
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
  SPXAssertTrueOrReturn(completion);
  self.completionBlock = completion;
  
  if (policy == SPXSecurePolicyNone) {
    completion([SPXSecureOnceSession new]);
    return;
  }
  
  if (policy == SPXSecurePolicyConfirmationOnly) {
    NSString *title = description ? [NSString stringWithFormat:@"Are you sure you want to %@?", description] : @"Are you sure?";
    [[[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:description ?: @"Continue" otherButtonTitles:nil] showInView:[UIApplication sharedApplication].keyWindow];
    return;
  }
  
  if (self.credential) {
    id <SPXSecureSession> session = [self sessionForPolicy:policy credential:credential];
    self.completionBlock(session);
    return;
  }
  
  if (!self.passcodeViewControllerClass) {
    // if no viewController is registered we can't possibly show a prompt, so no session is returned.
    SPXLog(@"You must call -registerPasscodeViewControllerClass: if you want Abracadabra to prompt for a passcode automatically");
    self.completionBlock(nil);
    return;
  }
  
  __weak typeof(self) weakInstance = self;
  __block id <SPXSecureSession> session = nil;
  
  dispatch_sync_main(^{
    id <SPXSecurePasscodeViewController> controller = [weakInstance.passcodeViewControllerClass.class new];
    SPXCAssertTrueOrReturn([controller respondsToSelector:@selector(transitionToState:animated:completion:)]);
    
    SPXSecurePasscodeViewControllerState state = (self.credential) ? SPXSecurePasscodeViewControllerStateAuthenticating : SPXSecurePasscodeViewControllerStateInitializing;
    UIViewController *viewController = (UIViewController *)controller;
    
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    UIViewController *presentingController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [presentingController presentViewController:viewController animated:YES completion:nil];
    
    [controller transitionToState:state animated:YES completion:^id<SPXSecureSession>(id<SPXSecureCredential> credential) {
      session = [weakInstance sessionForPolicy:policy credential:credential];
      return session;
    }];
  }, ^{
    self.completionBlock(session);
  });
}

- (id <SPXSecureSession>)sessionForPolicy:(SPXSecurePolicy)policy credential:(id <SPXSecureCredential>)credential
{
  id <SPXSecureSession> session = [SPXSecureOnceSession new];
  return session;
}

- (void)setDefaultTimeoutInterval:(NSTimeInterval)defaultTimeoutInterval
{
  _defaultTimeoutInterval = defaultTimeoutInterval;
  [self.timedSession invalidate];
}

//- (void)reset
//{
//  self.credential = nil;
//}
//
//- (void)resetPasscode
//{
//  if ([self authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN].isValid) {
//    
//  }
//}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  if (buttonIndex) {
    self.completionBlock(nil);
  } else {
    self.completionBlock([SPXSecureOnceSession new]);
  }
}

@end
