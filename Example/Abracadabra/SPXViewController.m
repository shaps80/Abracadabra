//
//  SPXViewController.m
//  Abracadabra
//
//  Created by Shaps Mohsenin on 02/02/2015.
//  Copyright (c) 2014 Shaps Mohsenin. All rights reserved.
//

#import "SPXViewController.h"
#import "SPXSecureEventsViewController.h"
#import "Abracadabra.h"

@interface SPXViewController ()
@end

@implementation SPXViewController

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  SPXSecure(SPXSecurityPolicyTimedSessionWithPIN, {
    NSLog(@"running code");
  });
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
    SPXSecureEventsViewController *controller = [SPXSecureEventsViewController new];
    
    [controller configureWithBlock:^(UITableViewController *controller) {
      
    }];
    
    [controller configureWithBlock:^(UITableViewController *controller) {
      controller.title = @"Another";
    }];
    
    
    
    // need to be able to configure sorting!
    
    
    
//    [controller.tableViewController.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SPXSecureEventCellIdentifier];
//    [self.navigationController pushViewController:controller.tableViewController animated:YES];
//    [self presentViewController:controller animated:YES completion:nil];
  });
}

@end

