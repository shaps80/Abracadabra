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

#import "SPXSecureEvent.h"
#import "SPXDefines.h"

@implementation SPXSecureEvent

@synthesize currentPolicy = _currentPolicy;

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  SPXAssertTrueOrReturnNil(self);
  
  SPXDecode(name);
  SPXDecode(identifier);
  SPXDecode(defaultPolicy);
  
  _currentPolicy = [[aDecoder decodeObjectForKey:SPXKeyPath(currentPolicy)] integerValue];
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  SPXEncode(currentPolicy);
  SPXEncode(name);
  SPXEncode(identifier);
  SPXEncode(defaultPolicy);
}

- (instancetype)init
{
  NSAssert(NO, @"You must call the designated initializer: -initWithIdentifier:name:policy:");
  return nil;
}

- (instancetype)initWithIdentifier:(NSString *)identifier name:(NSString *)name policy:(SPXSecurityPolicy)policy
{
  self = [super init];
  SPXAssertTrueOrReturnNil(self);
  
  SPXAssertTrueOrReturnNil(identifier.length);
  SPXAssertTrueOrReturnNil(name.length);
  
  _identifier = identifier;
  _name = name;
  _defaultPolicy = policy;
  
  NSNumber *currentPolicy = [[NSUserDefaults standardUserDefaults] objectForKey:_identifier];
  _currentPolicy = currentPolicy ? currentPolicy.integerValue : _defaultPolicy;
  
  return self;
}

- (void)setCurrentPolicy:(SPXSecurityPolicy)currentPolicy
{
  if (_currentPolicy == currentPolicy) {
    return;
  }
  
  _currentPolicy = currentPolicy;
  [[NSUserDefaults standardUserDefaults] setObject:@(currentPolicy) forKey:self.identifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)reset
{
  self.currentPolicy = self.defaultPolicy;
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.identifier];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)description
{
  return SPXDescription(SPXKeyPath(identifier), SPXKeyPath(name), SPXKeyPath(defaultPolicy), SPXKeyPath(currentPolicy));
}

@end

