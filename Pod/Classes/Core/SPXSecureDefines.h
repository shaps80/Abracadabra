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

#import "SPXSecureCredential.h"
#import "SPXSecureSession.h"


extern NSString *const SPXSecureVaultDidFailAuthenticationPermanently;


/**
 *  Defines the available security policies
 */
typedef NS_ENUM(NSInteger, SPXSecurePolicy) {
  /**
   *  An event will always be required to enter a PIN
   */
  SPXSecurePolicyAlwaysWithPIN,
  /**
   *  An event will only be required to enter a PIN if no valid session exists
   */
  SPXSecurePolicyTimedSessionWithPIN,
  /**
   *  An event will only be asked to confirm, no PIN is requested
   */
  SPXSecurePolicyConfirmationOnly,
  /**
   *  An event will be executed immediately, no confirmation or PIN will be requested
   */
  SPXSecurePolicyNone
};


typedef NS_ENUM(NSInteger, SPXSecurePasscodeViewControllerState)
{
  SPXSecurePasscodeViewControllerStateAuthenticating,
  SPXSecurePasscodeViewControllerStateInitializing,
};


/**
 *  Defines the protocol all passcode viewController's must conform to
 */
@protocol SPXSecurePasscodeViewController <NSObject>


/**
 *  This method will be called when the controller should transition to a new state. You should use this method to determine when a successful passcode was entered, and then dismiss the view controller. If (state == SPXSecurePasscodeViewControllerStateLocked) then no other transition will occur unless the Vault is reset.
 *
 *  @param state        The state to transition to.
 *  @param animated     If YES, you can choose to perform the changes with an animation
 *  @param completion   You should call this block with a valid credential to complete authentication
 */
- (void)transitionToState:(SPXSecurePasscodeViewControllerState)state animated:(BOOL)animated completion:(id<SPXSecureSession> (^)(id <SPXSecureCredential> credential))completion;


@end




