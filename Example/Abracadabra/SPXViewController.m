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
#import "SPXPasscodeViewController.h"

@interface SPXViewController ()
@end

@implementation SPXViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [[UIView appearanceWhenContainedIn:SPXPasscodeViewController.class, nil] setTintColor:[UIColor whiteColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  SPXSecureVault *vault = [SPXSecureVault defaultVault];
  SPXSecurePasscodeCredential *credential = [SPXSecurePasscodeCredential credentialWithPasscode:@"0000"];
  
  if (vault.hasCredential) {
    NSLog(@"Credential Found");
  } else {
    NSLog(@"No Credential Found");
  }
  
  vault.fallbackToConfirmation = NO;
  [vault registerPasscodeViewControllerClass:SPXPasscodeViewController.class];
  
  if (indexPath.section == 0) {
    switch (indexPath.row) {
      case 0:
        [vault authenticateWithPolicy:SPXSecurePolicyNone description:nil credential:nil completion:^(id<SPXSecureSession> session) {
          NSLog(@"%@: %zd", session, session.isValid);
        }];
        break;
      case 1:
        [vault authenticateWithPolicy:SPXSecurePolicyConfirmationOnly description:@"Restart Server" credential:nil completion:^(id<SPXSecureSession> session) {
          NSLog(@"%@: %zd", session, session.isValid);
        }];
        break;
      case 2:
        [vault authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN description:nil completion:^(id<SPXSecureSession> session) {
          NSLog(@"%@: %zd", session, session.isValid);
        }];
        break;
      case 3:
        [vault authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN description:nil credential:credential completion:^(id<SPXSecureSession> session) {
          NSLog(@"%@: %zd", session, session.isValid);
        }];
        break;
      case 4:
        vault.fallbackToConfirmation = YES;
        [vault registerPasscodeViewControllerClass:nil];
        
        [vault authenticateWithPolicy:SPXSecurePolicyAlwaysWithPIN description:nil credential:nil completion:^(id<SPXSecureSession> session) {
          NSLog(@"%@: %zd", session, session.isValid);
        }];
        break;
      case 5:
        [vault authenticateWithPolicy:SPXSecurePolicyTimedSessionWithPIN description:nil credential:nil completion:^(id<SPXSecureSession> session) {
          NSLog(@"%@: %zd", session, session.isValid);
        }];
        break;
      case 6:
        [vault authenticateWithPolicy:SPXSecurePolicyTimedSessionWithPIN description:nil credential:credential completion:^(id<SPXSecureSession> session) {
          NSLog(@"%@: %zd", session, session.isValid);
        }];
        break;
    }
  } else {
    switch (indexPath.row) {
      case 0:
        [vault updateCredentialWithCompletion:^(id<SPXSecureSession> session) {
          NSLog(@"%@: %zd", session, session.isValid);
        }];
        break;
      case 1:
        [vault updateCredentialWithExistingCredential:credential newCredential:credential completion:^(id<SPXSecureSession> session) {
          NSLog(@"%@: %zd", session, session.isValid);
        }];
        break;
      case 2:
        [vault removeCredentialWithCompletion:^{
          NSLog(@"Passcode removed");
        }];
        break;
    }
  }
}

@end


