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

#import "SPXSecureSession.h"
#import "SPXSecureCredential.h"
#import "SPXSecureDefines.h"

@protocol SPXSecureVaultDelegate;


/**
 *  The vault manages your passcode, sessions and authentication.
 *  You can optionally provide your own viewController classes to use for prompts and settings. 
 *  Leave these nil if you prefer to use the default viewController's.
 */
@interface SPXSecureVault : NSObject


/**
 *  Gets/sets the delegate that will respond to changes in the vault. Usually this is where you would hookup your UI
 */
@property (nonatomic, weak) id <SPXSecureVaultDelegate> delegate;


/**
 *  Gets/sets the maximum number of retries allowed before the vault is no longer accessible. (Defaults to 10)
 */
@property (nonatomic, assign) NSUInteger maximumRetryCount;


/**
 *  Sets the default session timeout interval (in seconds). Setting this value will reset the current session. (Defaults to 60 seconds)
 */
@property (nonatomic, assign) NSTimeInterval defaultTimeoutInterval;


/**
 *  Returns YES if an existing credential exists for this vault. NO otherwise.
 */
@property (nonatomic, readonly) BOOL hasCredential;


/**
 *  Returns a default singleton vault instance
 */
+ (instancetype)defaultVault;
+ (instancetype)vaultNamed:(NSString *)name;


/**
 *  Attempts to authenticate using the specified policy, with the given credentials. This method is useful when you don't want Abracadabra to present any UI
 *
 *  @param policy     The policy to use for this authentication
 *  @param credential The credential to use for this authentication
 *
 *  @return If a valid session exists, or the user authenticates successfully, the session is returned. nil otherwise
 */
- (void)authenticateWithPolicy:(SPXSecurePolicy)policy completion:(void (^)(id<SPXSecureSession>))completion;
- (void)authenticateWithPolicy:(SPXSecurePolicy)policy description:(NSString *)description credential:(id<SPXSecureCredential>)credential completion:(void (^)(id<SPXSecureSession>))completion;


/**
 *  Registers the specified class to use for prompting the user for a passcode (optional)
 *
 *  @param viewControllerClass The viewController class
 */
- (void)registerPasscodeViewControllerClass:(Class <SPXSecurePasscodeViewController>)viewControllerClass;


/**
 *  Registers the specified class to use for configuring the vault settings (optional)
 *
 *  @param viewControllerClass The viewController class
 */
- (void)registerVaultSettingsViewControllerClass:(Class)viewControllerClass;


/**
 *  If the vault has been permanently locked, this method will reset the vault to allow you to set a new passcode. This method should ONLY be called if you're sure its safe! If the vault is currentlt locked (not permanently) and you call this method, this method does nothing.
 *  If you're trying to reset the passcode use -resetPasscode below.
 */
- (void)reset;


/**
 *  Resets the current passcode. This method will call [self authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN] first to authenticate the user, if this is successful the passcode will then be reset
 */
- (void)resetPasscode;


@end



/**
 *  Defines the vault delegate
 */
@protocol SPXSecureVaultDelegate <NSObject>


/**
 *  This method will execute whenever an authentication attempt fails
 *
 *  @param vault            The vault that executed this method
 *  @param remainingRetries The number of allowed retries remaining on this vault before its locked permanently
 */
- (void)vault:(SPXSecureVault *)vault didFailAuthenticationWithRemainingRetryCount:(NSUInteger)remainingRetries;


/**
 *  This method will execute when the vault was locked due to the maximum number of retries being exceeded. The vault will no longer be accessible unless -reset is called
 *
 *  @param vault The vault that was locked
 */
- (void)vaultDidLock:(SPXSecureVault *)vault;


@end


