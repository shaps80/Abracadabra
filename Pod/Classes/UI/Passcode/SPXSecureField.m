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

#import "SPXSecureField.h"
#import "SPXAssertionDefines.h"

static const NSUInteger SPXSecureFieldNumberOfShakes = 6;
static const CGFloat SPXSecureFieldInitialShakeAmplitude = 40.0f;
static const CGFloat SPXSecureFieldVerticalSpacing = 15;
static const CGFloat SPXSecureFieldIndicatorSize = 15;

@interface SPXSecureField ()

@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) SPXSecureFieldState state;
@property (nonatomic, strong) NSArray *indicators;

@property (nonatomic, strong) NSMutableString *mutableText;
@property (nonatomic, strong) NSMutableDictionary *placeholderStrings;

@property (nonatomic, assign) NSUInteger numberOfShakes;
@property (nonatomic, assign) NSInteger shakeDirection;
@property (nonatomic, assign) CGFloat shakeAmplitude;

@end

@implementation SPXSecureField

@synthesize font = _font;
@synthesize indicatorSize = _indicatorSize;

- (NSString *)text
{
  return self.mutableText.copy;
}

- (UIView *)contentView
{
  if (_contentView) {
    return _contentView;
  }
  
  _contentView = [UIView new];
  _contentView.backgroundColor = [UIColor clearColor];
  
  [self addSubview:_contentView];
  return _contentView;
}

- (void)setViewStyle:(SPXSecureViewStyle)viewStyle
{
  _viewStyle = viewStyle;
  _placeholderLabel.textColor = self.currentColor;
}

- (UIColor *)currentColor
{
  return self.viewStyle ? [UIColor whiteColor] : [UIColor blackColor];
}

- (UILabel *)placeholderLabel
{
  if (_placeholderLabel) {
    return _placeholderLabel;
  }
  
  _placeholderLabel = [UILabel new];
  _placeholderLabel.backgroundColor = [UIColor clearColor];
  _placeholderLabel.font = self.font;
  _placeholderLabel.textColor = self.currentColor;
  _placeholderLabel.textAlignment = NSTextAlignmentCenter;
  _placeholderLabel.text = [self placeholderTextForState:SPXSecureFieldStateEnterPasscode];
  
  [self.contentView addSubview:_placeholderLabel];
  return _placeholderLabel;
}

- (NSArray *)indicators
{
  if (_indicators) {
    return _indicators;
  }
  
  NSMutableArray *indicators = [NSMutableArray new];
  
  for (int i = 0; i < 4; i++) {
    UIView *indicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SPXSecureFieldIndicatorSize, SPXSecureFieldIndicatorSize)];
    [self.contentView addSubview:indicator];
    [indicators addObject:indicator];
  }
  
  _indicators = indicators.copy;
  return _indicators;
}

- (NSMutableDictionary *)placeholderStrings
{
  return _placeholderStrings ?: (_placeholderStrings = [NSMutableDictionary new]);
}

- (void)updateIndicators:(BOOL)animated
{
  void(^update)() = ^() {
    for (int i = 0; i < 4; i++) {
      UIView *indicator = self.indicators[i];
      indicator.backgroundColor = self.currentColor;
      indicator.layer.cornerRadius = CGRectGetWidth(indicator.bounds) / 2;
      
      CGFloat spacing = CGRectGetWidth(indicator.bounds) * 1.5;
      CGFloat totalWidth = CGRectGetWidth(indicator.bounds) * 4;
      CGFloat totalSpacing = spacing * 3;
      CGFloat initialOffset = (CGRectGetWidth(self.contentView.bounds) - (totalWidth + totalSpacing)) / 2;
      
      CGRect rect = indicator.frame;
      rect.size = CGSizeMake(self.indicatorSize, self.indicatorSize);
      rect.origin.x = initialOffset + (spacing * i) + CGRectGetWidth(indicator.bounds) * i;
      rect.origin.y = (CGRectGetHeight(self.contentView.bounds) - CGRectGetHeight(indicator.bounds)) / 2 + SPXSecureFieldVerticalSpacing;
      indicator.frame = rect;
      
      NSInteger indicatorCount = self.mutableText.length;
      indicator.alpha = (i < indicatorCount) ? 1 : 0.2;
    }
  };
  
  if (!animated) {
    update();
    return;
  }
  
  [UIView animateWithDuration:0.2 animations:^{
    update();
  }];
}

- (void)transitionToState:(SPXSecureFieldState)state animationStyle:(SPXSecureFieldAnimationStyle)animationStyle
{
  [self animateWithStyle:animationStyle];
  [self transitionToState:state];
  [self updateIndicators:YES];
}

- (void)transitionToState:(SPXSecureFieldState)state
{
  _state = state;
  self.mutableText = [NSMutableString new];
  self.placeholderLabel.text = [self placeholderTextForState:state];
  self.placeholderLabel.textColor = self.currentColor;
  [self setNeedsLayout];
}

- (void)animateWithStyle:(SPXSecureFieldAnimationStyle)style
{
  if (style == SPXSecureFieldAnimationStyleNone) {
    return;
  }
  
  if (style == SPXSecureFieldAnimationStylePush || style == SPXSecureFieldAnimationStylePop || style == SPXSecureFieldAnimationStyleFade) {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2;
    
    if (style == SPXSecureFieldAnimationStyleFade) {
      transition.type = kCATransitionFade;
    }
    
    if (style == SPXSecureFieldAnimationStylePush) {
      transition.type = kCATransitionPush;
      transition.subtype = kCATransitionFromRight;
    }
    
    if (style == SPXSecureFieldAnimationStylePop) {
      transition.type = kCATransitionPush;
      transition.subtype = kCATransitionFromLeft;
    }
    
    [self.contentView.layer addAnimation:transition forKey:nil];
  } else {
    self.numberOfShakes = 0;
    self.shakeDirection = -1;
    self.shakeAmplitude = SPXSecureFieldInitialShakeAmplitude;
    [self performShake];
  }
}

- (void)performShake
{
  [UIView animateWithDuration:0.06f animations:^ {
    self.contentView.transform = CGAffineTransformMakeTranslation(self.shakeDirection * self.shakeAmplitude, 0.0f);
  } completion:^(BOOL finished) {
    if (self.numberOfShakes < SPXSecureFieldNumberOfShakes) {
      self.numberOfShakes++;
      self.shakeDirection = -1 * self.shakeDirection;
      self.shakeAmplitude = (SPXSecureFieldNumberOfShakes - self.numberOfShakes) * (SPXSecureFieldInitialShakeAmplitude / SPXSecureFieldNumberOfShakes);
      [self performShake];
    } else {
      self.transform = CGAffineTransformIdentity;
    }
  }];
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  self.contentView.frame = self.bounds;
  
  [self.placeholderLabel sizeToFit];
  
  CGRect rect = self.placeholderLabel.frame;
  rect.origin.x = 0;
  rect.origin.y = (CGRectGetHeight(self.contentView.bounds) - CGRectGetHeight([self.indicators.firstObject frame])) / 2 - SPXSecureFieldVerticalSpacing - 3;
  rect.size.width = CGRectGetWidth(self.contentView.bounds);
  self.placeholderLabel.frame = rect;
  
  [self updateIndicators:NO];
}

#pragma mark - Text

- (NSString *)placeholderTextForState:(SPXSecureFieldState)state
{
  switch (state) {
    case SPXSecureFieldStateEnterPasscode:
      return self.placeholderStrings[@(state)] ?: @"enter passcode";
    case SPXSecureFieldStateSetPasscode:
      return self.placeholderStrings[@(state)] ?: @"set passcode";
    case SPXSecureFieldStateConfirmPasscode:
      return self.placeholderStrings[@(state)] ?: @"confirm passcode";
    case SPXSecureFieldStateInvalidPasscode:
      return self.placeholderStrings[@(state)] ?: @"wrong passcode";
    case SPXSecureFieldStateMismatchPassCode:
      return self.placeholderStrings[@(state)] ?: @"passcode didn't match";
  }
}

- (void)setPlaceholderText:(NSString *)placeholder forState:(SPXSecureFieldState)state
{
  self.placeholderStrings[@(state)] = placeholder;
  [self transitionToState:self.state];
}

- (void)setFont:(UIFont *)font
{
  _font = font;
  self.placeholderLabel.font = font;
}

- (UIFont *)font
{
  if (_font) {
    return _font;
  }
  
  return [UIFont boldSystemFontOfSize:14];
}

- (CGFloat)indicatorSize
{
  return _indicatorSize ?: SPXSecureFieldIndicatorSize;
}

- (void)setIndicatorSize:(CGFloat)indicatorSize
{
  if (_indicatorSize == indicatorSize) {
    return;
  }
  
  _indicatorSize = indicatorSize;
  [self updateIndicators:NO];
}

#pragma mark - UIKeyInput

- (NSMutableString *)mutableText
{
  return _mutableText ?: (_mutableText = [NSMutableString new]);
}

- (BOOL)hasText
{
  return self.mutableText.length;
}

- (void)appendText:(NSString *)text
{
  if (self.text.length > 3) {
    return;
  }
  
  [self.mutableText appendString:[text substringToIndex:1]];
  [self updateIndicators:YES];
  
  if ([self.delegate respondsToSelector:@selector(secureFieldDidChange:)]) {
    [self.delegate secureFieldDidChange:self];
  }
}

- (void)deleteBackward
{
  if (!self.mutableText.length) {
    return;
  }
  
  NSRange range = NSMakeRange(self.mutableText.length - 1, 1);
  [self.mutableText deleteCharactersInRange:range];
  [self updateIndicators:YES];
  
  if ([self.delegate respondsToSelector:@selector(secureFieldDidChange:)]) {
    [self.delegate secureFieldDidChange:self];
  }
}

@end

