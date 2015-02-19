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

#import "SPXPasscodeViewController.h"
#import "SPXSecureVault.h"
#import "SPXPasscodeLayout.h"
#import "SPXAssertionDefines.h"
#import "SPXSecureKeyCell.h"
#import "SPXDefines.h"
#import "SPXSecureField.h"
#import "SPXAudio.h"
#import "UIImage+SPXSecureAdditions.h"

static CGFloat const SPXPasscodeKeyboardHeight = 300;
static CGFloat const SPXPasscodeiPadWidth = 320;
static CGFloat const SPXPasscodeiPadHeight = 480;

@interface SPXPasscodeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, SPXSecureFieldDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSDictionary *keyMappings;
@property (nonatomic, strong) SPXSecureField *secureField;
@property (nonatomic, strong) NSString *passcode;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) SPXSecurePasscodeViewControllerState state;
@property (nonatomic, strong) id<SPXSecureSession> (^completion)(id <SPXSecureCredential>);


@end

@implementation SPXPasscodeViewController

__attribute__((constructor)) static void SPXPasscodeViewControllerConstructor(void) {
  @autoreleasepool {
    [[SPXSecureVault defaultVault] registerPasscodeViewControllerClass:SPXPasscodeViewController.class];
  }
}

+ (instancetype)appearance
{
  return [self.class new];
}

+ (instancetype)appearanceWhenContainedIn:(Class<UIAppearanceContainer>)ContainerClass, ...
{
  return [self.class new];
}

- (void)setTintColor:(UIColor *)tintColor
{
  
  /*
   This will never get called to update the tintColor of each subview
   */
  
  
  
  
  self.collectionView.tintColor = tintColor;
  self.secureField.tintColor = tintColor;
}

- (instancetype)init
{
  self = [super init];
  SPXAssertTrueOrReturnNil(self);
  
  [self configureBackground];
  
  self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[SPXPasscodeLayout new]];
  self.collectionView.backgroundColor = [UIColor clearColor];
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  
  [self.collectionView registerClass:SPXSecureKeyCell.class forCellWithReuseIdentifier:@"key"];
  
  self.secureField = [SPXSecureField new];
  self.secureField.delegate = self;
  
  self.contentView = [UIView new];
  self.contentView.backgroundColor = [UIColor clearColor];
  self.contentView.clipsToBounds = YES;
  [self.contentView addSubview:self.collectionView];
  [self.contentView addSubview:self.secureField];
  
  self.keyMappings = @
  {
    @0  : @[ @"1",  @""       ],
    @1  : @[ @"2",  @"abc"    ],
    @2  : @[ @"3",  @"def"    ],
    @3  : @[ @"4",  @"ghi"    ],
    @4  : @[ @"5",  @"jkl"    ],
    @5  : @[ @"6",  @"mno"    ],
    @6  : @[ @"7",  @"pqrs"   ],
    @7  : @[ @"8",  @"tuv"    ],
    @8  : @[ @"9",  @"wxyz"   ],
    @9  : @[ @"",   @"cancel" ],
    @10 : @[ @"0",  @""       ],
    @11 : @[ @"",   @"back"   ],
  };
  
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self.view addSubview:self.imageView];
  [self.view addSubview:self.contentView];
}

- (void)configureBackground
{
  UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
  [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  self.imageView = [[UIImageView alloc] initWithImage:[image imageByApplyingLightEffect]];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  SPXSecureKeyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"key" forIndexPath:indexPath];
  
  NSArray *titles = self.keyMappings[@(indexPath.item)];
  [cell setTitle:titles[0] subtitle:titles[1]];
  cell.tintColor = self.view.tintColor;
  
  return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return 12;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  [collectionView deselectItemAtIndexPath:indexPath animated:YES];
  
  if (indexPath.item == 9) {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    return;
  }
  
  if (indexPath.item == 11) {
    if (!self.secureField.text.length && self.secureField.state == SPXSecureFieldStateConfirmPasscode) {
      [self.secureField transitionToState:SPXSecureFieldStateSetPasscode animationStyle:SPXSecureFieldAnimationStylePop];
    }
    
    [self.secureField deleteBackward];
    return;
  }
  
  NSString *text = [self.keyMappings[@(indexPath.item)] firstObject];
  [self.secureField appendText:text];
}

- (void)secureFieldDidChange:(SPXSecureField *)field
{
  if (self.state == SPXSecurePasscodeViewControllerStateInitializing) {
    BOOL readyForConfirmation = (field.text.length == 4 && field.state == SPXSecureFieldStateSetPasscode);
    
    if (readyForConfirmation) {
      self.passcode = field.text;
      [field transitionToState:SPXSecureFieldStateConfirmPasscode animationStyle:SPXSecureFieldAnimationStylePush];
    }
    
    BOOL mismatchedPasscode = (field.state == SPXSecureFieldStateMismatchPassCode);
    
    if (mismatchedPasscode) {
      NSString *text = field.text;
      [field transitionToState:SPXSecureFieldStateSetPasscode animationStyle:SPXSecureFieldAnimationStyleFade];
      [field appendText:text];
    }
    
    BOOL readyForCredential = (field.text.length == 4 && field.state == SPXSecureFieldStateConfirmPasscode);
    
    if (readyForCredential) {
      if ([self.passcode isEqualToString:field.text]) {
        SPXSecurePasscodeCredential *credential = [SPXSecurePasscodeCredential credentialWithPasscode:self.passcode];
        self.completion(credential);
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
      } else {
        [field transitionToState:SPXSecureFieldStateMismatchPassCode animationStyle:SPXSecureFieldAnimationStyleShake];
        [SPXAudio playSystemAudioType:SPXAudioTypeVibrate];
        self.passcode = nil;
      }
    }
  }
  
  if (self.state == SPXSecurePasscodeViewControllerStateAuthenticating) {
    BOOL invalidPasscode = field.state == SPXSecureFieldStateInvalidPasscode;
    
    if (invalidPasscode) {
      NSString *text = field.text;
      [field transitionToState:SPXSecureFieldStateEnterPasscode animationStyle:SPXSecureFieldAnimationStyleFade];
      [field appendText:text];
    }
    
    BOOL readyForCredential = (field.text.length == 4 && field.state == SPXSecureFieldStateEnterPasscode);
    
    if (readyForCredential) {
      SPXSecurePasscodeCredential *credential = [SPXSecurePasscodeCredential credentialWithPasscode:field.text];
      id <SPXSecureSession> session = self.completion(credential);
      
      if (session.isValid) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
      } else {
        [field transitionToState:SPXSecureFieldStateInvalidPasscode animationStyle:SPXSecureFieldAnimationStyleShake];
        [SPXAudio playSystemAudioType:SPXAudioTypeVibrate];
      }
    }
  }
}

- (void)transitionToState:(SPXSecurePasscodeViewControllerState)state animated:(BOOL)animated completion:(id<SPXSecureSession> (^)(id<SPXSecureCredential>))completion
{
  _state = state;
  self.passcode = nil;
  
  if (state == SPXSecurePasscodeViewControllerStateInitializing) {
    [self.secureField transitionToState:SPXSecureFieldStateSetPasscode animationStyle:SPXSecureFieldAnimationStyleNone];
  } else {
    [self.secureField transitionToState:SPXSecureFieldStateEnterPasscode animationStyle:SPXSecureFieldAnimationStyleNone];
  }
  
  self.completion = completion;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return UIStatusBarStyleLightContent;
}

- (CGRect)rectForContentView
{
  CGRect rect = self.view.bounds;
  
  if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
    rect.size.width = SPXPasscodeiPadWidth;
    rect.size.height = SPXPasscodeiPadHeight;
    
    rect.origin.x = (CGRectGetWidth(self.view.bounds) - CGRectGetWidth(rect)) / 2;
    rect.origin.y = (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(rect)) / 2;
  }
  
  return rect;
}

- (CGRect)rectForSecureField
{
  CGRect rect = self.contentView.bounds;
  rect.size.height -= SPXPasscodeKeyboardHeight;
  return rect;
}

- (CGRect)rectForCollectionView
{
  CGRect rect = self.contentView.bounds;
  rect.size.height = SPXPasscodeKeyboardHeight;
  rect.origin.y = CGRectGetHeight(self.contentView.bounds) - CGRectGetHeight(rect) + 1;
  return rect;
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
  
  self.imageView.frame = self.view.bounds;
  self.contentView.frame = [self rectForContentView];
  self.collectionView.frame = [self rectForCollectionView];
  self.secureField.frame = [self rectForSecureField];
}

@end


