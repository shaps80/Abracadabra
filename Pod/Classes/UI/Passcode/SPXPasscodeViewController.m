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

static SPXSecureViewStyle __viewStyle;
static UIColor * __tintColor;

@interface SPXPasscodeViewController () <UICollectionViewDataSource, UICollectionViewDelegate, SPXSecureFieldDelegate>

@property (nonatomic, strong) UIVisualEffectView *effectsView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSDictionary *keyMappings;
@property (nonatomic, strong) SPXSecureField *secureField;
@property (nonatomic, strong) NSString *passcode;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) SPXSecurePasscodeViewControllerState state;
@property (nonatomic, strong) id<SPXSecureSession> (^completion)(id <SPXSecureCredential>);
@property (nonatomic, assign) BOOL showNavigationBarOnDismiss;

@end

@implementation SPXPasscodeViewController

@synthesize presentationConfiguration = _presentationConfiguration;

__attribute__((constructor)) static void SPXPasscodeViewControllerConstructor(void) {
  @autoreleasepool {
    [[SPXSecureVault defaultVault] registerPasscodeViewControllerClass:SPXPasscodeViewController.class];
  }
}

+ (void)setViewStyle:(SPXSecureViewStyle)style
{
  __viewStyle = style;
  [[SPXSecureField appearance] setViewStyle:style];
  [[SPXSecureKeyCell appearance] setViewStyle:style];
}

+ (void)setTintColor:(UIColor *)color
{
  __tintColor = color;
}

- (instancetype)init
{
  self = [super init];
  SPXAssertTrueOrReturnNil(self);
  
  _imageView = [UIImageView new];
  _imageView.contentMode = UIViewContentModeScaleAspectFill;
  
  _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[SPXPasscodeLayout new]];
  _collectionView.backgroundColor = [UIColor clearColor];
  _collectionView.dataSource = self;
  _collectionView.delegate = self;
  _collectionView.scrollEnabled = NO;
  _collectionView.delaysContentTouches = NO;
  
  [_collectionView registerClass:SPXSecureKeyCell.class forCellWithReuseIdentifier:@"key"];
  
  _secureField = [SPXSecureField new];
  _secureField.delegate = self;
  
  _contentView = [UIView new];
  _contentView.backgroundColor = [UIColor clearColor];
  _contentView.clipsToBounds = YES;
  [_contentView addSubview:_collectionView];
  [_contentView addSubview:_secureField];
  
  _keyMappings = @
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

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self updateBackground];
  [self.view addSubview:self.imageView];
  [self.view addSubview:self.contentView];
  
  __weak typeof(self) weakInstance = self;
  [[NSNotificationCenter defaultCenter] addObserver:weakInstance selector:@selector(dismissViewController:) name:SPXSecureVaultDidFailAuthenticationPermanently object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidResign) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)applicationDidResign
{
  self.completion(nil);
  [self dismissViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.showNavigationBarOnDismiss = !self.navigationController.navigationBarHidden;
  [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [self.navigationController setNavigationBarHidden:!self.showNavigationBarOnDismiss animated:animated];
}

- (void)dismissViewController:(BOOL)canceled
{
  if (!self.presentationConfiguration.dismissOnCompletion && !canceled) {
    return;
  }

  [self dismissViewController];
}

- (void)dismissViewController
{
  if (self.navigationController) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
  }
}

- (void)updateBackground
{
  UIView *view = [UIApplication sharedApplication].keyWindow.rootViewController.view;
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, [UIScreen mainScreen].scale);
  [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
 
  if (__tintColor) {
    image = [image imageByApplyingBlurRadius:15 tintColor:__tintColor saturationDeltaFactor:1.5 maskImage:nil];
  } else {
    image = __viewStyle ? [image imageByApplyingDarkEffect] : [image imageByApplyingLightEffect];
  }
  
  self.imageView.image = image;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  SPXSecureKeyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"key" forIndexPath:indexPath];
  
  NSArray *titles = self.keyMappings[@(indexPath.item)];
  
  if (indexPath.item == 9 && !self.presentationConfiguration.allowsCancel) {
    return cell;
  }
  
  [cell setTitle:titles[0] subtitle:titles[1]];
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
    [self dismissViewController:YES];
    self.completion(nil);
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

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.item == 9 && !self.presentationConfiguration.allowsCancel) {
    return NO;
  }
  
  return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.item == 9 && !self.presentationConfiguration.allowsCancel) {
    return NO;
  }
  
  return YES;
}

- (void)secureFieldDidChange:(SPXSecureField *)field
{
  if (self.state == SPXSecurePasscodeViewControllerStateAuthenticating || self.state == SPXSecurePasscodeViewControllerStateUpdating) {
    [self handleAuthenticationStates];
  } else {
    [self handleInitializationStates];
  }
}

- (void)handleInitializationStates
{
  BOOL readyForConfirmation = (self.secureField.text.length == 4 && self.secureField.state == SPXSecureFieldStateSetPasscode);
  
  if (readyForConfirmation) {
    self.passcode = self.secureField.text;
    [self.secureField transitionToState:SPXSecureFieldStateConfirmPasscode animationStyle:SPXSecureFieldAnimationStylePush];
  }
  
  BOOL mismatchedPasscode = (self.secureField.state == SPXSecureFieldStateMismatchPassCode);
  
  if (mismatchedPasscode) {
    NSString *text = self.secureField.text;
    [self.secureField transitionToState:SPXSecureFieldStateSetPasscode animationStyle:SPXSecureFieldAnimationStyleFade];
    [self.secureField appendText:text];
  }
  
  BOOL readyForCredential = (self.secureField.text.length == 4 && self.secureField.state == SPXSecureFieldStateConfirmPasscode);
  
  if (readyForCredential) {
    if ([self.passcode isEqualToString:self.secureField.text]) {
      SPXSecurePasscodeCredential *credential = [SPXSecurePasscodeCredential credentialWithPasscode:self.passcode];
      self.completion(credential);
      [self dismissViewController:NO];
    } else {
      [self.secureField transitionToState:SPXSecureFieldStateMismatchPassCode animationStyle:SPXSecureFieldAnimationStyleShake];
      [SPXAudio vibrate];
      self.passcode = nil;
    }
  }
}

- (void)handleAuthenticationStates
{
  BOOL invalidPasscode = self.secureField.state == SPXSecureFieldStateInvalidPasscode;
  
  if (invalidPasscode) {
    NSString *text = self.secureField.text;
    [self.secureField transitionToState:SPXSecureFieldStateEnterPasscode animationStyle:SPXSecureFieldAnimationStyleFade];
    [self.secureField appendText:text];
  }
  
  BOOL readyForCredential = (self.secureField.text.length == 4 && self.secureField.state == SPXSecureFieldStateEnterPasscode);
  
  if (readyForCredential) {
    SPXSecurePasscodeCredential *credential = [SPXSecurePasscodeCredential credentialWithPasscode:self.secureField.text];
    id <SPXSecureSession> session = self.completion(credential);
    
    if (session) {
      if (self.state != SPXSecurePasscodeViewControllerStateUpdating) {
        [self dismissViewController:NO];
      }
    } else {
      [self.secureField transitionToState:SPXSecureFieldStateInvalidPasscode animationStyle:SPXSecureFieldAnimationStyleShake];
      [SPXAudio vibrate];
    }
  }
}

- (void)transitionToState:(SPXSecurePasscodeViewControllerState)state animated:(BOOL)animated completion:(id<SPXSecureSession> (^)(id<SPXSecureCredential>))completion
{
  if (state == SPXSecurePasscodeViewControllerStateInitializing) {
    if (self.state == SPXSecurePasscodeViewControllerStateUpdating) {
      [self.secureField transitionToState:SPXSecureFieldStateSetPasscode animationStyle:SPXSecureFieldAnimationStylePush];
    } else {
      [self.secureField transitionToState:SPXSecureFieldStateSetPasscode animationStyle:SPXSecureFieldAnimationStyleNone];
    }
  } else {
    [self.secureField transitionToState:SPXSecureFieldStateEnterPasscode animationStyle:SPXSecureFieldAnimationStyleNone];
  }
  
  _state = state;
  self.passcode = nil;
  self.completion = completion;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
  return (UIStatusBarStyle)__viewStyle;
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
  CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
  
  if (self.prefersStatusBarHidden) {
    statusBarHeight = 0;
  }
  
  CGRect rect = self.contentView.bounds;
  rect.size.height -= SPXPasscodeKeyboardHeight;
  rect.origin.y += statusBarHeight;
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
  
  [self.collectionView.collectionViewLayout invalidateLayout];
}

@end



