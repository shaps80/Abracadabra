/*
   Copyright (c) 2015 Snippex. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY Snippex `AS IS' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL Snippex OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SPXDataValidator.h"


/**
 *  Defines a protocol that all credential's should conform to
 */
@protocol SPXSecureCredential <NSCoding>


/**
 *  Returns a secure string representatino of the credential. This value will be used to store your credential in the keychain
 *
 *  @return A secure string representation
 */
- (NSString *)secureCredential;


/**
 *  Determines if 2 credential's have identical values or not
 *
 *  @param credential The credential to compare to this credential
 *
 *  @return YES if their secure values are equal, NO otherwise
 */
- (BOOL)isEqualToCredential:(id <SPXSecureCredential>)credential;


@end



/**
 *  Provides an object that encapsulates a passcode credential
 */
@interface SPXSecurePasscodeCredential : NSObject <SPXSecureCredential>


/**
 *  Returns a new instance with the specified passcode
 *
 *  @param passcode  The passcode this credential will represent
 *  @param validator When a validator is passed, it will be used to validate the supplied passcode. Passing nil is allowed
 *
 *  @return A new instance of SPXSecureCredential
 */
+ (instancetype)credentialWithPasscode:(NSString *)passcode;


@end

