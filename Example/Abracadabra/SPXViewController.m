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
#import "SPXSecureKeyCell.h"

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
  [[SPXSecureField appearance] setFont:[UIFont fontWithName:@"Verdana" size:15]];
  [[SPXSecureKeyCell appearance] setFont:[UIFont fontWithName:@"Verdana" size:30]];
  [SPXPasscodeViewController setViewStyle:SPXSecureViewStyleLightContent];
}

- (IBAction)configureEvents:(id)sender
{
  [self presentViewController:[[SPXSecureVault defaultVault] eventsViewController] animated:YES completion:nil];
}

- (IBAction)configureVault:(id)sender
{
  [self presentViewController:[[SPXSecureVault defaultVault] settingsViewController] animated:YES completion:nil];
}

- (void)macroAuthenticationWithIndexPath:(NSIndexPath *)indexPath
{
  // the following implementations are mostly are identical to some of the code below and are provided here for reference only. This is the recommended implementation
  
  SPXSecureVault *vault = [SPXSecureVault defaultVault];
  
  if (indexPath.section == 0) {
    switch (indexPath.row) {
      case 0:
        Abracadabra(@"Authentication", @"No Authentication", SPXSecurePolicyNone, NSLog(@"Success"), NSLog(@"Failed"))
        break;
      case 1:
        Abracadabra(@"Authentication", @"Authenticate with Confirmation", SPXSecurePolicyConfirmationOnly, NSLog(@"Success"), NSLog(@"Failed"))
        break;
      case 2:
        vault.fallbackToConfirmation = YES;
        Abracadabra(@"Authentication", @"Authentication with Passcode", SPXSecurePolicyAlwaysWithPIN, {
          NSLog(@"Success");
        }, NSLog(@"Failed"))
        break;
      case 4:
        vault.fallbackToConfirmation = YES;
        [vault registerPasscodeViewControllerClass:nil];
        
        Abracadabra(@"Authentication", @"Authenticate with Fallback", SPXSecurePolicyTimedSessionWithPIN, {
          NSLog(@"Success");
        })
        break;
      case 5:
        Abracadabra(@"Authentication", @"Authenticate with Timeout", SPXSecurePolicyTimedSessionWithPIN, NSLog(@"Success"), NSLog(@"Failed"))
        break;
      default:
        [self authenticateWithIndexPath:indexPath];
        break;
    }
  }
  
  if (indexPath.section) {
    [self authenticateWithIndexPath:indexPath];
  }
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
        vault.fallbackToConfirmation = YES;
        [vault authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN description:@"Restart Server" completion:^(id<SPXSecureSession> session) {
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
    [self selectIndexPath:indexPath];
  });
#else
  [self selectIndexPath:indexPath];
#endif
}

- (void)selectIndexPath:(NSIndexPath *)indexPath
{
#define MACRO
#ifdef MACRO
  [self macroAuthenticationWithIndexPath:indexPath];
#else
  [self authenticateWithIndexPath:indexPath];
#endif
}

@end


