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

#import <Kiwi/Kiwi.h>
#import "SPXSecureEventsStore.h"


SPEC_BEGIN(SPXSecureEventsStoreSpec)

describe(@"SPXSecureEventsStore", ^{
  
  SPXSecureEventsStore *store = [SPXSecureEventsStore sharedInstance];
  SPXSecureEventsGroup *group = [[SPXSecureEventsGroup alloc] initWithName:@"Group"];
  SPXSecureEvent *event = [[SPXSecureEvent alloc] initWithIdentifier:@"1234" name:@"Event" policy:SPXSecurityPolicyNone];
  
  context(@"Store", ^{
    it(@"should have discovered 1 group from SPXSecurityTestClass", ^{
      SPXSecureEventsGroup *security = [store eventGroupWithName:@"Security"];
      [[[store should] have:1] eventGroups];
      [[[security should] have:2] events];
    });
    
    it(@"should have discovered 1 event from SPXSecurityTestClass", ^{
      [[[store.eventGroups should] have:1] events];
    });
    
    it(@"should add 1 group", ^{
      [[theBlock(^{
        [store addEventGroup:group];
      }) should] change:^{ return (NSInteger)[store.eventGroups count]; } by:+1];
    });
    
    it(@"should remove 1 group", ^{
      [[theBlock(^{
        [store removeEventGroup:group];
      }) should] change:^{ return (NSInteger)[store.eventGroups count]; } by:-1];
    });
  });
  
  context(@"Groups", ^{
    it(@"group name should equal 'Group'", ^{
      [[group.name should] equal:@"Group"];
    });
    
    it(@"should have 1 event", ^{
      [[theBlock(^{
        [group addEvent:event];
      }) should] change:^{ return (NSInteger)[group.events count]; } by:+1];
    });
    
    it(@"should have 0 events", ^{
      [[theBlock(^{
        [group removeEvent:event];
      }) should] change:^{ return (NSInteger)[group.events count]; } by:-1];
    });
  });
  
  context(@"Events", ^{
    it(@"name should equal 'Event'", ^{
      [[event.name should] equal:@"Event"];
    });
    
    it(@"identifier should equal '1234'", ^{
      [[event.identifier should] equal:@"1234"];
    });
    
    it(@"default policy should equal 3", ^{
      [[theValue(event.defaultPolicy) should] equal:theValue(3)];
    });
    
    it(@"current policy should equal 0", ^{
      event.currentPolicy = SPXSecurityPolicyTimedSessionWithPIN;
      [[theValue(event.currentPolicy) should] equal:theValue(1)];
    });
  });
  
});

SPEC_END
