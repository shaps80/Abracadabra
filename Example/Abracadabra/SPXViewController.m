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

- (IBAction)add:(id)sender
{
  SPXSecureVault *vault = [SPXSecureVault vaultNamed:@"test"];
  
  if (vault.hasCredential) {
    NSLog(@"Has credential");
  } else {
    NSLog(@"Settings Credential");
  }
  
  SPXSecurePasscodeCredential *credential = [SPXSecurePasscodeCredential credentialWithPasscode:@"0000"];
  [vault authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN description:nil credential:credential completion:^(id<SPXSecureSession> session) {
    if (session.isValid) {
      NSLog(@"Success");
    } else {
      NSLog(@"Failed");
    }
  }];
  
//  Abracadabra(SPXSecurePolicyAlwaysWithPIN, NSLog(@"Success"), NSLog(@"Failed"));
}

@end


