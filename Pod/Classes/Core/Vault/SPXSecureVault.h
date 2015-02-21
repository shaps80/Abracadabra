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

#import <UIKit/UIKit.h>

#import "SPXSecureSession.h"
#import "SPXSecureCredential.h"
#import "SPXSecureDefines.h"


extern NSString *const SPXSecureVaultDidFailAuthenticationPermanently;


typedef void (^SPXSecureVaultAuthenticationCompletionBlock)(id <SPXSecureSession> session);
typedef void (^SPXSecureVaultCompletionBlock)(BOOL success);


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
 *  Its not recommended that you allow this value to change at runtime
 *
 *  @note Pass a value of 0 to allow unlimited retries
 */
@property (nonatomic, assign) NSUInteger maximumRetryCount;


/**
 *  Returns the number of allowed retries remaining.
 */
@property (nonatomic, readonly) NSUInteger remainingRetryCount;


/**
 *  Sets the default session timeout interval (in seconds). Setting this value will reset the current session. (Defaults to 60 seconds)
 *
 *  @note Pass 0 to use default. Negative values will default to 0
 */
@property (nonatomic, assign) NSTimeInterval defaultTimeoutInterval;


/**
 *  Gets/sets whether an alertView should be used instead of the action sheet on iPhone. iPad will always use an alertView
 */
@property (nonatomic, assign) BOOL useAlertViewForConfirmation;


/**
 *  Returns YES if an existing credential exists for this vault. NO otherwise.
 */
@property (nonatomic, readonly) BOOL hasCredential;


/**
 *  Returns YES if the vault is currently locked, NO otherwise
 */
@property (nonatomic, readonly) BOOL isLocked;


/**
 *  Gets/sets whether or not an authentication method should fallback to confirmation when a id<SPXPasscodeViewController> hasn't been registered
 */
@property (nonatomic, assign) BOOL fallbackToConfirmation;



#pragma mark - Initializers



/**
 *  Returns a default singleton vault instance
 */
+ (instancetype)defaultVault;


/**
 *  Returns the vault wiht the specified name. If it doesn't exist it will be created and returned. (this method never returns nil)
 *
 *  @param name The name of the vault to return. This name should be unqiue and will be used to store the credential in the keychain
 *
 *  @return A cached vault
 */
+ (instancetype)vaultNamed:(NSString *)name;



#pragma mark - Authentication



/**
 *  Attempts to authenticate using the specified policy, with the given credentials. This method is useful when you don't want Abracadabra to present any UI
 *
 *  @param policy      The policy to use for this authentication
 *  @param description A textual description, this will be used in an alert when policy == SPXSecurePolicyConfirmationOnly
 *  @param completion  The block to execute when authentication has completed. If the authentication was valid, a valid session will be returned, otherwise nil
 */
- (void)authenticateWithPolicy:(SPXSecurePolicy)policy description:(NSString *)description completion:(SPXSecureVaultAuthenticationCompletionBlock)completion;


/**
 *  Attempts to authenticate using the specified policy, with the given credentials. This method is useful when you don't want Abracadabra to present any UI
 *
 *  @param policy      The policy to use for this authentication
 *  @param description A textual description, this will be used in an alert when policy == SPXSecurePolicyConfirmationOnly
 *  @param credential  The credential to use for this authentication
 *  @param completion  The block to execute when authentication has completed. If the authentication was valid, a valid session will be returned, otherwise nil
 */
- (void)authenticateWithPolicy:(SPXSecurePolicy)policy description:(NSString *)description credential:(id <SPXSecureCredential>)credential completion:(SPXSecureVaultAuthenticationCompletionBlock)completion;



#pragma mark - Manage Credential



/**
 *  Updates the current passcode. This is similar to calling -removePasscode followed by -authenticateWithPolicy:completion: -- However this method won't dismiss the view until the procedure is complete
 *
 *  @param completion   The block to execute when the update completes. If the update was successful, YES is returned. NO otherwise
 */
- (void)updateCredentialWithCompletion:(SPXSecureVaultCompletionBlock)completion;

/**
 *  Updates the current passcode. This is similar to calling -removePasscode followed by -authenticateWithPolicy:completion: -- However this method won't dismiss the view until the procedure is complete
 *
 *  @param existingCredential Create an equivalent credential and pass that here to perform authentication without UI
 *  @param newCredential      The new credential to set on this vault
 *  @param completion         The block to execute when the update completes. If the update was successful, YES is returned. NO otherwise
 *
 *  @note If no credential currently exists, this is equivalent to calling -authenticateWithPolicy:completion: and setting up a new passcode
 */
- (void)updateCredentialWithExistingCredential:(id <SPXSecureCredential>)existingCredential newCredential:(id <SPXSecureCredential>)newCredential completion:(SPXSecureVaultCompletionBlock)completion;


/**
 *  If the vault has been permanently locked, this method will reset the vault to allow you to set a new passcode. This method should ONLY be called if you're sure its safe! If the vault is currentlt locked (not permanently) and you call this method, this method does nothing.
 *  If you're trying to reset the passcode use -resetPasscode below.
 */
- (void)resetVault;


/**
 *  Resets the current passcode. This method will call [self authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN] first to authenticate the user, if this is successful the passcode will then be reset
 */
- (void)removeCredentialWithCompletion:(SPXSecureVaultCompletionBlock)completion;



#pragma mark - Presentation



- (UIViewController *)eventsViewController;
- (UIViewController *)settingsViewController;



#pragma mark - ViewControllers



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
 *  Registers the specified class to use for presenting the secure events found in your code. This can be used to allow runtime policy changes to your users
 *
 *  @param viewControllerClass The viewController class
 */
- (void)registerEventsViewControllerClass:(Class)viewControllerClass;


@end



#pragma mark - Delegate



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


