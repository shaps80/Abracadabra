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
 *  Provides a collection view cell for allowing input
 */
@interface SPXSecureKeyCell : UICollectionViewCell


/**
 *  Gets/sets the appearance style to apply to this cell
 */
@property (nonatomic, assign) SPXSecureViewStyle viewStyle UI_APPEARANCE_SELECTOR;

/**
 *  Gets/sets the font to apply to this cell's label
 */
@property (nonatomic, strong) UIFont *font UI_APPEARANCE_SELECTOR;


/**
 *  Sets the titles for this cell's label
 *
 *  @param title    This will usually be the KeyPad number (0 ... 9)
 *  @param subtitle This will usually be the KeyPad characters (abc ... xzy)
 */
- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle;


@end

