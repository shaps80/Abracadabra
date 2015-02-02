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

@interface SPXSecureSession ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval interval;
@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, strong) SPXSecureCredential *credential;

@end


/**
 We should call CACurrentMediaTime() and store its value. This is the current time since last reboot!
 When we create a new session we can store this since its not based on calendar, etc..
 When checking the session, we can then compare the current CACurrentMediaTime() to the stored one.
 
  CFTimeInterval elapsedTime = storedTime - CACurrentMediaTime();
 
  if (elapsedTime > timeout || elapsedTime <= 0) {
    // session is NOT valid!
  }
 
 */

@implementation SPXSecureSession

- (instancetype)initWithDomain:(SPXSecureDomain *)domain
{
  self = [super init];
  if (!self) return nil;
  
  _timeout = domain.settings.timeoutInterval;
  
  return self;
}

- (BOOL)isValid
{
  return (self.timeRemaining > 0);
}

- (NSTimeInterval)timeRemaining
{
  return self.timeout - self.interval;
}

- (NSString *)isSessionValid
{
  return self.isValid ? @"YES" : @"NO";
}

- (NSString *)description
{
  return SPXDescription(SPXKeyPath(isSessionValid), SPXKeyPath(timeRemaining), SPXKeyPath(timeout));
}

@end

