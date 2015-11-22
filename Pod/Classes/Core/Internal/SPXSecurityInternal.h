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

#ifndef _SPX_SECURITY_INTERNAL_H
#define _SPX_SECURITY_INTERNAL_H

#import "SPXDefinesCommon.h"
#import "SPXSecureEventsStore.h"


#define _SPXSecuritySegmentName "__DATA"
#define _SPXSecuritySectionName "SPXSecurity"

typedef __unsafe_unretained NSString *_SPXSecureLiteralString;

typedef struct {
  _SPXSecureLiteralString *group;
  _SPXSecureLiteralString *name;
  NSInteger defaultPolicy;
} spx_secure_entry;

extern NSString *_SPXSecurityIdentifier(spx_secure_entry *entry);


#define __SPXSecurityConcat_(X, Y) X ## Y
#define __SPXSecurityConcat(X, Y) __SPXSecurityConcat_(X, Y)

#define __SPXSecurityIndex(_1, _2, _3, _4, _5, value, ...) value
#define __SPXSecurityIndexCount(...) __SPXSecurityIndex(__VA_ARGS__, 5, 4, 3, 2, 1)

#define __SPXSecurityHasOption1(__withPolicyOnly, __withoutName, __withoutNameAndAction, __withName, __withNameAndAction, ...) __withPolicyOnly
#define __SPXSecurityHasOption2(__withPolicyOnly, __withoutName, __withoutNameAndAction, __withName, __withNameAndAction, ...) __withoutName
#define __SPXSecurityHasOption3(__withPolicyOnly, __withoutName, __withoutNameAndAction, __withName, __withNameAndAction, ...) __withoutNameAndAction
#define __SPXSecurityHasOption4(__withPolicyOnly, __withoutName, __withoutNameAndAction, __withName, __withNameAndAction, ...) __withName
#define __SPXSecurityHasOption5(__withPolicyOnly, __withoutName, __withoutNameAndAction, __withName, __withNameAndAction, ...) __withNameAndAction


#define _SPXSecurityHasOptions(__withPolicyOnly, __withoutName, __withoutNameAndAction, __withName, __withNameAndAction, ...) \
  __SPXSecurityConcat(__SPXSecurityHasOption, __SPXSecurityIndexCount(__VA_ARGS__))(__withPolicyOnly, __withoutName, __withoutNameAndAction, __withName, __withNameAndAction)

#define _SPXSecureInternal(...) \
  _SPXSecurityHasOptions(_SPXSecureInternalWithPolicyOnly, _SPXSecureInternalWithoutName, _SPXSecureInternalWithoutNameAndAction, _SPXSecureInternalWithName, _SPXSecureInternalWithNameAndAction, __VA_ARGS__)(__VA_ARGS__)

#define _SPXSecureInternalWithPolicyOnly(policy_, code_) _SPXSecureCode(nil, nil, policy_, ;, ;)
#define _SPXSecureInternalWithoutName(policy_, code_) _SPXSecureCode(nil, nil, policy_, code_, ;)
#define _SPXSecureInternalWithoutNameAndAction(policy_, code_, action_) _SPXSecureCode(nil, nil, policy_, code_, action_)
#define _SPXSecureInternalWithName(group_, name_, policy_, code_) _SPXSecureCode(group_, name_, policy_, code_, ;)
#define _SPXSecureInternalWithNameAndAction(group_, name_, policy_, code_, action_) _SPXSecureCode(group_, name_, policy_, code_, action_)

#define _SPXSecureCode(group_, name_, policy_, code_, action_) ({ \
  SPXSecurePolicy policy = policy_; \
  \
  if ((group_) && (name_)) { \
    SPXSecureEvent *event = _SPXGetSecureEventInternal(group_, name_, policy_); \
    policy = event.currentPolicy; \
  } \
  \
  [[SPXSecureVault defaultVault] authenticateWithPolicy:policy description:name_ credential:nil configuration:nil completion:^(id<SPXSecureSession> session, id <SPXSecurePasscodeViewController> controller) { \
    if (session.isValid) { code_; } else { action_; } \
  }]; \
});

#define _SPXGetSecureEventInternal(group_, name_, policy_) \
((^{ \
  /* store the data in the binary at compile time. */ \
  __attribute__((used)) static _SPXSecureLiteralString group__ = group_; \
  __attribute__((used)) static _SPXSecureLiteralString name__ = name_; \
  \
  __attribute__((used)) __attribute__((section (_SPXSecuritySegmentName "," _SPXSecuritySectionName))) static spx_secure_entry entry = \
  { &group__, &name__, policy_ }; \
  \
  /* find the registered event with the given identifier. */ \
  SPXSecureEventsStore *store = [SPXSecureEventsStore sharedInstance]; \
  SPXSecureEventsGroup *group = [store eventGroupWithName:group__]; \
  \
  NSString *identifier = _SPXSecurityIdentifier(&entry); \
  SPXSecureEvent *event = [group eventWithIdentifier:identifier]; \
  \
  return event; \
})())


#endif

