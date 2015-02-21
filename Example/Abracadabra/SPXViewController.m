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

#import "SPXLoggingDefines.h"

@interface SPXViewController () <SPXSecureVaultDelegate>
@end

@implementation SPXViewController

- (void)vault:(SPXSecureVault *)vault didFailAuthenticationWithRemainingRetryCount:(NSUInteger)remainingRetries
{
  NSLog(@"Remaining retries: %zd", remainingRetries);
}

-(void)vaultDidLock:(SPXSecureVault *)vault
{
  [[[UIAlertView alloc] initWithTitle:@"LOCKED" message:@"Vault was locked" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
 
  [SPXSecureVault defaultVault].delegate = self;
  [SPXPasscodeViewController setViewStyle:SPXSecureViewStyleLightContent];
//  [SPXPasscodeViewController setTintColor:[UIColor colorWithRed:0.918 green:1.000 blue:0.580 alpha:0.700]];
//  [SPXPasscodeViewController setTintColor:[UIColor colorWithRed:0.153 green:0.667 blue:0.910 alpha:0.75]];
}

- (void)authenticateWithIndexPath:(NSIndexPath *)indexPath
{
  SPXSecureVault *vault = [SPXSecureVault defaultVault];
  SPXSecurePasscodeCredential *credential = [SPXSecurePasscodeCredential credentialWithPasscode:@"0000"];
  
  vault.fallbackToConfirmation = NO;
  [vault registerPasscodeViewControllerClass:SPXPasscodeViewController.class];
  
  if (indexPath.section == 0) {
    switch (indexPath.row) {
      case 0:
        [vault authenticateWithPolicy:SPXSecurePolicyNone description:nil credential:nil completion:^(id<SPXSecureSession> session) {
          if (session.isValid) { NSLog(@"Success"); } else { NSLog(@"Failed"); }
        }];
        break;
      case 1:
        [vault authenticateWithPolicy:SPXSecurePolicyConfirmationOnly description:@"Restart Server" credential:nil completion:^(id<SPXSecureSession> session) {
          if (session.isValid) { NSLog(@"Success"); } else { NSLog(@"Failed"); }
        }];
        break;
      case 2:
        [vault authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN description:nil completion:^(id<SPXSecureSession> session) {
          if (session.isValid) { NSLog(@"Success"); } else { NSLog(@"Failed"); }
        }];
        break;
      case 3:
        [vault authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN description:nil credential:credential completion:^(id<SPXSecureSession> session) {
          if (session.isValid) { NSLog(@"Success"); } else { NSLog(@"Failed"); }
        }];
        break;
      case 4:
        vault.fallbackToConfirmation = YES;
        [vault registerPasscodeViewControllerClass:nil];
        
        [vault authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN description:nil credential:nil completion:^(id<SPXSecureSession> session) {
          if (session.isValid) { NSLog(@"Success"); } else { NSLog(@"Failed"); }
        }];
        break;
      case 5:
        [vault authenticateWithPolicy:SPXSecurePolicyTimedSessionWithPIN description:nil credential:nil completion:^(id<SPXSecureSession> session) {
          if (session.isValid) { NSLog(@"Success"); } else { NSLog(@"Failed"); }
        }];
        break;
      case 6:
        [vault authenticateWithPolicy:SPXSecurePolicyTimedSessionWithPIN description:nil credential:credential completion:^(id<SPXSecureSession> session) {
          if (session.isValid) { NSLog(@"Success"); } else { NSLog(@"Failed"); }
        }];
        break;
    }
  } else if (indexPath.section == 1) {
    switch (indexPath.row) {
      case 0:
        [vault updateCredentialWithCompletion:^(BOOL success) {
          if (success) { NSLog(@"Success"); } else { NSLog(@"Failed"); }
        }];
        break;
      case 1:
        [vault updateCredentialWithExistingCredential:credential newCredential:credential completion:^(BOOL success) {
          if (success) { NSLog(@"Success"); } else { NSLog(@"Failed"); }
        }];
        break;
      case 2:
        [vault removeCredentialWithCompletion:^ (BOOL success) {
          if (success) { NSLog(@"Success"); } else { NSLog(@"Failed"); }
        }];
        break;
    }
  } else {
    [vault resetVault];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
#define DISPATCH
  
#ifdef DISPATCH
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    [self authenticateWithIndexPath:indexPath];
  });
#else
  [self authenticateWithIndexPath:indexPath];
#endif
}

@end


