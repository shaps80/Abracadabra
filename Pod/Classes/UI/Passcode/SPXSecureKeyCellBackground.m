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

#import "SPXSecureKeyCellBackground.h"

@interface SPXSecureKeyCellBackground ()
@property (nonatomic, assign) UIEdgeInsets textInsets;
@property (nonatomic, assign) UIEdgeInsets separatorInsets;
@property (nonatomic, assign) BOOL selected;
@end

@implementation SPXSecureKeyCellBackground

+ (instancetype)viewWithTextInsets:(UIEdgeInsets)textInsets separatorInsets:(UIEdgeInsets)separatorInsets
{
  SPXSecureKeyCellBackground *background = [SPXSecureKeyCellBackground new];
  background.textInsets = textInsets;
  background.separatorInsets = separatorInsets;
  background.backgroundColor = [UIColor clearColor];
  return background;
}

+ (instancetype)selectedViewWithTextInsets:(UIEdgeInsets)textInsets
{
  SPXSecureKeyCellBackground *background = [SPXSecureKeyCellBackground new];
  background.textInsets = textInsets;
  background.backgroundColor = [UIColor clearColor];
  background.selected = YES;
  return background;
}

- (void)setTintColor:(UIColor *)tintColor
{
  [super setTintColor:tintColor];
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)frame
{
  [super drawRect:frame];
  
  CGFloat pixel = 1;
  
  if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
    pixel = 1 / [UIScreen mainScreen].nativeScale;
  } else {
    pixel = 1 / [UIScreen mainScreen].scale;
  }
  
  
  if (self.selected) {
    CGRect rect = frame;
    rect.size.width -= self.textInsets.left / 2;
    rect.origin.x = self.textInsets.left / 2;
    rect = CGRectIntegral(rect);
    
    [[self.tintColor colorWithAlphaComponent:0.2] setFill];
    UIRectFill(rect);
  }
  
  if (!self.selected) {
    CGRect rect = frame;
    rect.origin.x = self.separatorInsets.left;
    rect.size.width -= (self.separatorInsets.left + self.separatorInsets.right);
    rect.size.height = pixel;
    rect.origin.y = CGRectGetHeight(frame) - CGRectGetHeight(rect) - pixel;
    
    [[self.tintColor colorWithAlphaComponent:0.5] setFill];
    UIRectFill(rect);
  }
}

@end