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

#import "SPXSecureDefines.h"

typedef NS_ENUM(NSInteger, SPXSecureFieldState)
{
  SPXSecureFieldStateEnterPasscode,
  SPXSecureFieldStateSetPasscode,
  SPXSecureFieldStateConfirmPasscode,
  SPXSecureFieldStateInvalidPasscode,
  SPXSecureFieldStateMismatchPassCode
};

typedef NS_ENUM(NSInteger, SPXSecureFieldAnimationStyle)
{
  SPXSecureFieldAnimationStyleNone,
  SPXSecureFieldAnimationStylePush,
  SPXSecureFieldAnimationStylePop,
  SPXSecureFieldAnimationStyleFade,
  SPXSecureFieldAnimationStyleShake,
};


@protocol SPXSecureFieldDelegate;

@interface SPXSecureField : UIView

@property (nonatomic, weak) id <SPXSecureFieldDelegate> delegate;

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) SPXSecureFieldState state;

@property (nonatomic, assign) CGFloat indicatorSize UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) SPXSecureViewStyle viewStyle UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIFont *font UI_APPEARANCE_SELECTOR;

- (void)setPlaceholderText:(NSString *)placeholder forState:(SPXSecureFieldState)state UI_APPEARANCE_SELECTOR;
- (void)transitionToState:(SPXSecureFieldState)state animationStyle:(SPXSecureFieldAnimationStyle)animationStyle;

- (void)appendText:(NSString *)text;
- (void)deleteBackward;

@end

@protocol SPXSecureFieldDelegate <NSObject>

- (void)secureFieldDidChange:(SPXSecureField *)field;

@end