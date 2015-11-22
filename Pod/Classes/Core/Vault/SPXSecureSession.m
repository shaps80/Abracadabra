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

#import "SPXSecureSession.h"
#import "SPXDefines.h"
#import "SPXSecureVault.h"

@interface SPXSecureOnceSession ()
@property (nonatomic, assign) dispatch_once_t onceToken;
@end

@implementation SPXSecureOnceSession

+ (instancetype)session
{
  return [SPXSecureOnceSession new];
}

- (BOOL)isValid
{
  __block BOOL isValid = NO;
  
  dispatch_once(&_onceToken, ^{
    isValid = YES;
  });
  
  return isValid;
}

- (void)invalidate { /* don't need to do anything */ }

@end

@interface SPXSecureTimedSession ()
@property (nonatomic, assign) CFTimeInterval createdAt;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@end

@implementation SPXSecureTimedSession

+ (instancetype)sessionWithTimeoutInterval:(NSTimeInterval)timeout
{
  SPXSecureTimedSession *session = [SPXSecureTimedSession new];
  session.timeoutInterval = timeout;
  session.createdAt = CACurrentMediaTime();
  return session;
}

- (BOOL)isValid
{
  CFTimeInterval elapsedTime = CACurrentMediaTime() - self.createdAt;
  return (elapsedTime < self.timeoutInterval && elapsedTime > 0);
}

- (NSString *)timeRemaining
{
  CFTimeInterval elapsedTime = CACurrentMediaTime() - self.createdAt;
  CFTimeInterval timeRemaining = MAX(floor(self.timeoutInterval - elapsedTime), 0);
  return [NSString stringWithFormat:@"%.0f seconds", timeRemaining];
}

- (void)invalidate
{
  self.timeoutInterval = 0;
}

- (NSString *)description
{
  return SPXDescription(SPXKeyPath(isValid), SPXKeyPath(timeRemaining));
}

@end

@interface SPXSecureAppSession ()
@property (nonatomic, assign) BOOL isValid;
@end

@implementation SPXSecureAppSession

+ (instancetype)session
{
  return [SPXSecureAppSession new];
}

- (instancetype)init
{
  self = [super init];
  SPXAssertTrueOrReturnNil(self);
  _isValid = YES;
  return self;
}

- (void)invalidate
{
  self.isValid = NO;
}

- (NSString *)description
{
  return SPXDescription(SPXKeyPath(isValid));
}

@end


