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

#import "SPXSecureCredential.h"
#import "NSData+SPXSecureAdditions.h"
#import "SPXDefines.h"
#import "SPXEncodingDefines.h"

@interface SPXSecurePasscodeCredential ()
@property (nonatomic, strong) NSString *secureCredential;
@end

@implementation SPXSecurePasscodeCredential

+ (instancetype)credentialWithPasscode:(NSString *)passcode
{
  SPXAssertTrueOrReturnNil(passcode);
  
  SPXSecurePasscodeCredential *credential = [SPXSecurePasscodeCredential new];
  credential.secureCredential = [passcode dataUsingEncoding:NSUTF8StringEncoding].spx_secureSHA2Value;
  
  return credential;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  
  SPXAssertTrueOrReturnNil(self);
  SPXDecode(secureCredential);
  
  return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
  SPXEncode(secureCredential);
}

- (BOOL)isEqualToCredential:(id<SPXSecureCredential>)credential
{
  NSString *c1 = [credential secureCredential];
  NSString *c2 = [self secureCredential];
  
  return ([c1 isEqualToString:c2]);
}

- (NSString *)description
{
  return SPXDescription(SPXKeyPath(secureCredential));
}

@end

