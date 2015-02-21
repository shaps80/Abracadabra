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

#import "SPXEventsViewController.h"
#import "SPXDefines.h"
#import "SPXSecureEventsStore.h"
#import "SPXSecureVault.h"
#import "SPXPoliciesViewController.h"

@interface SPXEventsViewController ()
@property (nonatomic, weak) SPXSecureEventsStore *store;
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) NSMutableDictionary *groupToEventsMappings;
@end

@implementation SPXEventsViewController

__attribute__((constructor)) static void SPXEventsViewControllerConstructor(void) {
  @autoreleasepool {
    [[SPXSecureVault defaultVault] registerEventsViewControllerClass:SPXEventsViewController.class];
  }
}

- (instancetype)init
{
  self = [super initWithStyle:UITableViewStyleGrouped];
  SPXAssertTrueOrReturnNil(self);
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.store = [SPXSecureEventsStore sharedInstance];
  self.groups = [self.store.eventGroups sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ]];
  self.groupToEventsMappings = [NSMutableDictionary new];
  
  self.title = @"Secure Events";
  UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
  self.navigationItem.rightBarButtonItem = done;
}

- (void)dismiss
{
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  SPXSecureEventsGroup *group = self.groups[section];
  return group.name;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  SPXSecureEventsGroup *group = self.groups[section];
  return group.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *const SPXSecureEventCellIdentifier = @"SPXSecureEventCellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SPXSecureEventCellIdentifier];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SPXSecureEventCellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  
  SPXSecureEventsGroup *group = self.groups[indexPath.section];
  NSArray *events = self.groupToEventsMappings[@(indexPath.section)];
  
  if (!events) {
    events = [group.events sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ]];
    self.groupToEventsMappings[@(indexPath.section)] = events;
  }
  
  cell.textLabel.text = [events[indexPath.item] name];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray *events = self.groupToEventsMappings[@(indexPath.section)]; 
  SPXPoliciesViewController *policies = [[SPXPoliciesViewController alloc] initWithEvent:events[indexPath.item]];
  [self.navigationController pushViewController:policies animated:YES];
}

@end
