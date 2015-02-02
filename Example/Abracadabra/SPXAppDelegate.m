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
    NSLog(@"Nothing");
  });
  
//  NSURLSession *session = [NSURLSession sharedSession];
//  NSURL *URL = [NSURL URLWithString:@"http://api.server.com/server?id=23213&action=restart"];
//  NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//  NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
//  [task resume];
  
  return YES;
}

@end
