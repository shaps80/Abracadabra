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

#import "SPXSecureEventsGroup.h"
#import "SPXDefines.h"

@interface SPXSecureEventsGroup ()
@property (nonatomic, strong) NSMutableDictionary *eventsIdentifierMapping;
@end

@implementation SPXSecureEventsGroup

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  SPXAssertTrueOrReturnNil(self);
  
  SPXDecode(name);
  SPXDecode(eventsIdentifierMapping);
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  SPXEncode(name);
  SPXEncode(eventsIdentifierMapping);
}

- (instancetype)initWithName:(NSString *)name
{
  self = [super init];
  SPXAssertTrueOrReturnNil(self);
  _name = name;
  return self;
}

- (NSArray *)events
{
  return self.eventsIdentifierMapping.allValues;
}

- (SPXSecureEvent *)eventWithIdentifier:(NSString *)identifier
{
  return self.eventsIdentifierMapping[identifier];
}

- (void)addEvent:(SPXSecureEvent *)event
{
  SPXAssertTrueOrReturn(!self.eventsIdentifierMapping[event.identifier]);
  self.eventsIdentifierMapping[event.identifier] = event;
}

- (void)removeEvent:(SPXSecureEvent *)event
{
  self.eventsIdentifierMapping[event.identifier] = nil;
}

- (NSMutableDictionary *)eventsIdentifierMapping
{
  return _eventsIdentifierMapping ?: (_eventsIdentifierMapping = [NSMutableDictionary new]);
}

- (NSString *)description
{
  return SPXDescription(SPXKeyPath(name), SPXKeyPath(events));
}

@end
