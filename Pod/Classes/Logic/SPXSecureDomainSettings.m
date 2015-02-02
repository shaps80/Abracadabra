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

#import "SPXSecureDomainSettings.h"
#import "SPXEncodingDefines.h"
#import "SPXDefines.h"

@interface SPXSecureDomainSettings ()
@property (nonatomic, assign) NSUInteger maximumRetryCount;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@end

@implementation SPXSecureDomainSettings

- (void)copyAttributesToInstance:(SPXSecureDomainSettings *)instance
{
  instance->_maximumRetryCount = self.maximumRetryCount;
  instance->_timeoutInterval = self.timeoutInterval;
}

- (id)mutableCopy
{
  SPXMutableSecureDomainSettings *settings = [SPXMutableSecureDomainSettings new];
  [self copyAttributesToInstance:settings];
  return settings;
}

- (id)copyWithZone:(NSZone *)zone
{
  SPXSecureDomainSettings *settings = [SPXSecureDomainSettings new];
  [self copyAttributesToInstance:settings];
  return settings;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (!self) return nil;
  
  SPXDecode(maximumRetryCount);
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  SPXEncode(maximumRetryCount);
}

- (NSString *)description
{
  return SPXDescription(SPXKeyPath(maximumRetryCount));
}

@end


@implementation SPXMutableSecureDomainSettings
@end

