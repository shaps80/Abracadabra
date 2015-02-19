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


/**
 *  Defines a secure event. An event is used to determine the security policy to apply before executing some piece of code
 */
@interface SPXSecureEvent : NSObject <NSCoding>


/**
 *  A unique identifier used to represent this event (readonly)
 */
@property (nonatomic, copy, readonly) NSString *identifier;


/**
 *  A friendly name, can be used in your user interface (readonly)
 */
@property (nonatomic, copy, readonly) NSString *name;


/**
 *  The default security policy applied to this event (readonly)
 */
@property (nonatomic, assign, readonly) SPXSecurePolicy defaultPolicy;


/**
 *  The current security policy applied to this event. This value is persistent.
 */
@property (nonatomic, assign) SPXSecurePolicy currentPolicy;


/**
 *  Initializes a new event
 *
 *  @param identifier The identifier to apply to this event
 *  @param name       The friendly name to apply to this event
 *  @param policy     The default security policy to apply to this event
 *
 *  @return A new instance of SPXSecureEvent
 */
- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name policy:(SPXSecurePolicy)policy;


/**
 *  Resets the current policy to its default. This method also removes the current persistent state
 */
- (void)reset;


@end

