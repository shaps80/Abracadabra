//
//  SPXViewController.m
//  Abracadabra
//
//  Created by Shaps Mohsenin on 02/02/2015.
//  Copyright (c) 2014 Shaps Mohsenin. All rights reserved.
//

#import "SPXViewController.h"
#import "Abracadabra.h"

#import "SPXSecureField.h"
#import "SPXPasscodeViewController.h"

@interface SPXViewController ()
@end

@implementation SPXViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [[UIView appearanceWhenContainedIn:SPXPasscodeViewController.class, nil] setTintColor:[UIColor whiteColor]];
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];
}

- (IBAction)add:(id)sender
{
  NSLog(@"Add: %@", [NSThread currentThread]);

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSLog(@"Background: %@", [NSThread currentThread]);
    
    Abracadabra(@"Group", @"Restart Server", SPXSecurePolicyAlwaysWithPIN, {
      NSLog(@"Success: %@", [NSThread currentThread]);
    })
  });
}

@end

