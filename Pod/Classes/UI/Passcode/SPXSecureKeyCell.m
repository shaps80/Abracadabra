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

#import "SPXSecureKeyCell.h"
#import "SPXSecureKeyCellBackground.h"

static CGFloat SPXSecureKeyCellDefaultFontSize = 30;

@interface SPXSecureKeyCell ()
@property (nonatomic, assign) UIEdgeInsets textInsets;
@property (nonatomic, assign) UIEdgeInsets separatorInsets;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@end

@implementation SPXSecureKeyCell

- (void)didMoveToSuperview
{
  [super didMoveToSuperview];
  
  CGFloat width = [[NSAttributedString alloc] initWithString:@"  " attributes:self.titleAttributes].size.width;
  [self setTextInsets:UIEdgeInsetsMake(20, 10, 0, 0) separatorInsets:UIEdgeInsetsMake(0, 20 + width, 0, 0)];
}

- (void)setTextInsets:(UIEdgeInsets)textInsets separatorInsets:(UIEdgeInsets)separatorInsets
{
  _textInsets = textInsets;
  _separatorInsets = separatorInsets;
  
  self.backgroundView = [SPXSecureKeyCellBackground viewWithTextInsets:textInsets separatorInsets:separatorInsets];
  self.selectedBackgroundView = [SPXSecureKeyCellBackground selectedViewWithTextInsets:textInsets];
  self.backgroundView.tintColor = self.currentColor;
  self.selectedBackgroundView.tintColor = self.currentColor;
}

- (UIView *)separatorView
{
  return _separatorView ?: ({
    UIView *separatorView = [UIView new];
    [self.contentView addSubview:separatorView];
    _separatorView = separatorView;
  });
}

- (UILabel *)label
{
  return _label ?: ({
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = self.font;
    [self.contentView addSubview:label];
    _label = label;
  });
}

- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle
{
  NSString *spacing = @" ";
  
  _title = [[title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAppendingString:spacing];
  _subtitle = [subtitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  [self updateTitles];
}

- (NSDictionary *)titleAttributes
{
  UIFont *font = self.font ?: [UIFont systemFontOfSize:SPXSecureKeyCellDefaultFontSize];
  
  return @{
    NSFontAttributeName : [font fontWithSize:font.pointSize],
    NSForegroundColorAttributeName : self.currentColor,
  };
}

- (NSDictionary *)subtitleAttributes
{
  UIFont *font = self.font ?: [UIFont systemFontOfSize:SPXSecureKeyCellDefaultFontSize];
  
  return @{
    NSFontAttributeName : [font fontWithSize:font.pointSize / 2],
    NSForegroundColorAttributeName : self.currentColor,
  };
}

- (UIColor *)currentColor
{
  return self.viewStyle ? [UIColor whiteColor] : [UIColor blackColor];
}

- (void)setViewStyle:(SPXSecureViewStyle)viewStyle
{
  _viewStyle = viewStyle;
  [self setTextInsets:self.textInsets separatorInsets:self.separatorInsets];
  [self updateTitles];
}

- (void)setFont:(UIFont *)font
{
  _font = font;
  [self updateTitles];
}

- (void)updateTitles
{
  if (!self.title) {
    return;
  }
  
  NSMutableAttributedString *string = [NSMutableAttributedString new];
  
  [string appendAttributedString:[[NSAttributedString alloc] initWithString:self.title attributes:self.titleAttributes]];
  [string appendAttributedString:[[NSAttributedString alloc] initWithString:self.subtitle attributes:self.subtitleAttributes]];
  
  self.label.attributedText = string;
  self.label.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  CGRect rect = self.bounds;
  
  rect.origin.x = self.textInsets.left;
  rect.origin.y = self.textInsets.top;
  rect.size.width = CGRectGetWidth(self.bounds) - (self.textInsets.left + self.textInsets.right);
  rect.size.height = CGRectGetHeight(self.bounds) - (self.textInsets.top + self.textInsets.bottom);
  
  self.label.frame = CGRectIntegral(rect);
}

@end
