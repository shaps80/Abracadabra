/*
   Copyright (c) 2014 Snippex. All rights reserved.

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

#import "UIImage+SecurityAdditions.h"
#import "SPXAssertionDefines.h"

@implementation UIImage (DrizzleAdditions)

+ (UIImage *)imageWithSize:(CGSize)size fillColor:(UIColor *)fill
{
  return [self imageWithSize:size fillColor:fill strokeColor:nil];
}

+ (UIImage *)imageWithSize:(CGSize)size strokeColor:(UIColor *)stroke
{
  return [self imageWithSize:size fillColor:nil strokeColor:stroke];
}

+ (UIImage *)imageWithSize:(CGSize)size fillColor:(UIColor *)fill strokeColor:(UIColor *)stroke
{
  SPXAssertTrueOrReturnNil(!CGSizeEqualToSize(size, CGSizeZero));
  
  int bitmapBytesPerRow = (int)(size.width * 4);
  
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef context = CGBitmapContextCreate(NULL, (size_t)size.width, (size_t)size.height, 8, (size_t)bitmapBytesPerRow, colorSpace,  (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
  CGRect rect = CGRectMake(0, 0, size.width, size.height);
  
  if (fill) {
    CGContextSetFillColorWithColor(context, fill.CGColor);
    CGContextFillRect(context, rect);
  }
  
  if (stroke) {
    CGContextSetFillColorWithColor(context, stroke.CGColor);
    CGContextStrokeRect(context, rect);
  }
  
  CGImageRef cgImage = CGBitmapContextCreateImage(context);
  UIImage *image = [UIImage imageWithCGImage:cgImage];
  
  CGImageRelease(cgImage);
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  
  return image;
}

@end
