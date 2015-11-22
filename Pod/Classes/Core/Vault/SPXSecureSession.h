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

#import <Foundation/Foundation.h>
#import "SPXSecureCredential.h"



/**
 *  Defines a protocol that all session's should conform to.
 */
@protocol SPXSecureSession <NSObject>


/**
 *  This method should be implemented in your subclasses to determine whether or not a session is valid
 *
 *  @return YES if the session is valid, NO otherwise
 */
- (BOOL)isValid;


/**
 *  Invalidates the session
 */
- (void)invalidate;


@end


/**
 *  Provides a single-use session. This session will only return YES once for -isValid
 */
@interface SPXSecureOnceSession : NSObject <SPXSecureSession>


/**
 *  Equivalent to calling [SPXSecureOnceSession new]
 *
 *  @return A new single-use session
 */
+ (instancetype)session;


@end



/**
 *  Provides a time-based session. This session will return YES while the timout
 */
@interface SPXSecureTimedSession : NSObject <SPXSecureSession>


/**
 *  Creates a new time-based session with the specified timeout interval
 *
 *  @param timeout The timeout interval before this session should be invalidated
 *
 *  @return A new time-based session
 */
+ (instancetype)sessionWithTimeoutInterval:(NSTimeInterval)timeout;


@end


/**
 *  Provides an application wide session. This session will return NO if the vaults defaultTimeoutInterval has been exceeded while the application is in the background. YES otherwise
 */
@interface SPXSecureAppSession : NSObject <SPXSecureSession>


/**
 *  Equivalent to calling [SPXSecureAppSession new]
 *
 *  @return A new application session
 */
+ (instancetype)session;


@end


