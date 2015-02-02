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

#import "SPXSecureEventsStore.h"
#import "SPXDefines.h"

@interface SPXSecureEventsStore ()
@property (nonatomic, strong) NSMutableDictionary *groupsNameMapping;
@end

@implementation SPXSecureEventsStore

+ (instancetype)sharedInstance
{
  static SPXSecureEventsStore *_sharedInstance = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  SPXAssertTrueOrReturnNil(self);
  SPXDecode(groupsNameMapping);
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  SPXEncode(groupsNameMapping);
}

- (SPXSecureEventsGroup *)eventGroupWithName:(NSString *)name
{
  return self.groupsNameMapping[name];
}

- (void)addEventGroup:(SPXSecureEventsGroup *)group
{
  SPXAssertTrueOrReturn(group);
  SPXAssertTrueOrReturn(!self.groupsNameMapping[group.name]);
  self.groupsNameMapping[group.name] = group;
}

- (void)removeEventGroup:(SPXSecureEventsGroup *)group
{
  [self.groupsNameMapping removeObjectForKey:group.name];
}

- (void)resetDefaults
{
  for (SPXSecureEventsGroup *group in self.eventGroups) {
    for (SPXSecureEvent *event in group.events) {
      event.currentPolicy = event.defaultPolicy;
    }
  }
}

- (NSArray *)eventGroups
{
  return self.groupsNameMapping.allValues;
}

- (NSMutableDictionary *)groupsNameMapping
{
  return _groupsNameMapping ?: (_groupsNameMapping = [NSMutableDictionary new]);
}

- (NSString *)description
{
  return SPXDescription(SPXKeyPath(eventGroups));
}

@end
