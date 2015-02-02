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


#ifndef _ABRACADABRA_H
#define _ABRACADABRA_H

#import "SPXSecurityInternal.h"


/**
 *  Convenience macros for securing your code easily. All 'code' is guaranteed to run on the calling thread. No need to dispatch
 *
 *  @param policy The security policy to apply to this code
 *  @param code   The code to secure
 *  @param ...    You can optionally pass some code that will execute ONLY if access is disallowed
 *
 *  @example
 *
 *    SPXSecure(SPXSecureEventPolicyAlways, {
 *      // your code goes here
 *    })
 *
 *    or
 *
 *    SPXSecure(SPXSecureEventPolicyAlways, {
 *      // your code goes here
 *    }, return)
 *
 *  You can also opt in to providing a group and name, this allows you to query the store for it at runtime and present UI
 *
 *  @param group  A group name for this event
 *  @param name   A friendly name for this event
 *
 *  @example
 *
 *    SPXSecure(@"Servers", @"Restart Server", SPXSecureEventPolicyAlways, {
 *      // your code goes here (restart the server)
 *    })
 *
 *    or
 *
 *    SPXSecure(@"Servers", @"Restart Server", SPXSecureEventPolicyAlways, {
 *      // your code goes here (restart the server)
 *    }, return)
 */
#define SPXSecure(...) _SPXSecureInternal(__VA_ARGS__)

#endif

