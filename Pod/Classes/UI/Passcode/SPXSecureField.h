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


/**
 *  Defines the possible states for this field
 */
typedef NS_ENUM(NSInteger, SPXSecureFieldState){
  /**
   *  The field is displaying the set passcode state
   */
  SPXSecureFieldStateEnterPasscode,
  /**
   *  The field is displaying a new passcode state
   */
  SPXSecureFieldStateSetPasscode,
  /**
   *  The field is displaying a confirmation state
   */
  SPXSecureFieldStateConfirmPasscode,
  /**
   *  The field is displaying an invalid state
   */
  SPXSecureFieldStateInvalidPasscode,
  /**
   *  The field is displaying a passcode mismatch state
   */
  SPXSecureFieldStateMismatchPassCode
};


/**
 *  Defines the possible animation styles for the field
 */
typedef NS_ENUM(NSInteger, SPXSecureFieldAnimationStyle){
  /**
   *  Specified no animation should occur
   */
  SPXSecureFieldAnimationStyleNone,
  /**
   *  Specified the field should transition to the next state with a push animation
   */
  SPXSecureFieldAnimationStylePush,
  /**
   *  Specified the field should transition to the next state with a pop animation
   */
  SPXSecureFieldAnimationStylePop,
  /**
   *  Specified the field should transition to the next state with a fade animation
   */
  SPXSecureFieldAnimationStyleFade,
  /**
   *  Specified the field should transition to the next state with a shake animation
   */
  SPXSecureFieldAnimationStyleShake,
};


@protocol SPXSecureFieldDelegate;


/**
 *  A secure field can be used to show passcode entry feedback
 */
@interface SPXSecureField : UIView


/**
 *  Gets/sets the delegte for this field
 */
@property (nonatomic, weak) id <SPXSecureFieldDelegate> delegate;


/**
 *  Gets the current passcode text for this field
 */
@property (nonatomic, readonly) NSString *text;


/**
 *  Gets the current state of this field
 */
@property (nonatomic, readonly) SPXSecureFieldState state;


/**
 *  Gets/sets the indicator size to use for this field
 */
@property (nonatomic, assign) CGFloat indicatorSize UI_APPEARANCE_SELECTOR;


/**
 *  Gets/sets the appearance style to use for this field
 */
@property (nonatomic, assign) SPXSecureViewStyle viewStyle UI_APPEARANCE_SELECTOR;


/**
 *  Gets/sets the font to use for this field
 */
@property (nonatomic, strong) UIFont *font UI_APPEARANCE_SELECTOR;


/**
 *  Gets 
 *
 *  @param placeholder <#placeholder description#>
 *  @param state       <#state description#>
 */
- (void)setPlaceholderText:(NSString *)placeholder forState:(SPXSecureFieldState)state UI_APPEARANCE_SELECTOR;
- (void)transitionToState:(SPXSecureFieldState)state animationStyle:(SPXSecureFieldAnimationStyle)animationStyle;

- (void)appendText:(NSString *)text;
- (void)deleteBackward;


@end


/**
 *  Defines a delegate to be used when you need updates about the secure field. This is generally going to be your passcodeViewController
 */
@protocol SPXSecureFieldDelegate <NSObject>


/**
 *  This method will be called whenever the text is changed
 *
 *  @param field The field that was changed
 */
- (void)secureFieldDidChange:(SPXSecureField *)field;


@end

