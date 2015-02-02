//
//  SPXAppDelegate.m
//  Abracadabra
//
//  Created by CocoaPods on 02/02/2015.
//  Copyright (c) 2014 Shaps Mohsenin. All rights reserved.
//

#import "SPXAppDelegate.h"
#import "Abracadabra.h"

@implementation SPXAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  SPXSecure(SPXSecurityPolicyNone, {
     /* this code will execute if access is allowed */
  })
  
  SPXSecure(@"", @"", SPXSecurityPolicyNone, {
     /* this code will execute if access is allowed */
  })
  
  SPXSecure(SPXSecurityPolicyNone, {
     /* this code will execute if access is allowed */
  }, /* this code will execute if access is disallowed */ )
  
  SPXSecure(@"", @"", SPXSecurityPolicyNone, {
     /* this code will execute if access is allowed */
  }, /* this code will execute if access is disallowed */ )
  
  return YES;
}

@end
