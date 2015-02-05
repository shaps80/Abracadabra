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

#import "SPXSecureEventsViewController.h"
#import "SPXSecureEventsStore.h"
#import "SPXDefines.h"

NSString *const SPXSecureEventCellIdentifier = @"EventCell";

@interface SPXSecureEventsTableViewController : UITableViewController
@property (nonatomic, copy) void (^configurationBlock)(UITableViewController *tableViewController);
@property (nonatomic, weak) SPXSecureEventsStore *store;
@property (nonatomic, strong) NSMutableArray *groups;
@end

@interface SPXSecureEventsViewController ()
@property (nonatomic, strong) SPXSecureEventsTableViewController *tableViewController;
@end

@implementation SPXSecureEventsViewController

- (instancetype)init
{
  self = [super init];
  SPXAssertTrueOrReturnNil(self);
  
  _tableViewController = [[SPXSecureEventsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
  [self pushViewController:self.tableViewController animated:NO];
  
  return self;
}

- (void)configureWithBlock:(void (^)(UITableViewController *))configurationBlock
{
  ((SPXSecureEventsTableViewController *)self.tableViewController).configurationBlock = configurationBlock;
}

@end


@implementation SPXSecureEventsTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.store = [SPXSecureEventsStore sharedInstance];
  
  self.title = @"Secure Events";
  !self.configurationBlock ?: self.configurationBlock(self);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.store.eventGroups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  SPXSecureEventsGroup *group = self.store.eventGroups[section];
  return group.events.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  SPXSecureEventsGroup *group = self.store.eventGroups[section];
  return group.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SPXSecureEventCellIdentifier];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SPXSecureEventCellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.textColor = [UIColor grayColor];
  }
  
  SPXSecureEventsGroup *group = self.store.eventGroups[indexPath.section];
  SPXSecureEvent *event = group.events[indexPath.item];
  
  cell.textLabel.text = event.name;
  cell.detailTextLabel.text = [self currentPolicyString:event.currentPolicy];
  
  return cell;
}

- (NSString *)currentPolicyString:(SPXSecurityPolicy)policy
{
  switch (policy) {
    case SPXSecurityPolicyAlwaysWithPIN:
      return @"Always require passcode";
    case SPXSecurityPolicyTimedSessionWithPIN:
      return @"Session based passcode";
    case SPXSecurityPolicyConfirmationOnly:
      return @"Confirmation only";
    case SPXSecurityPolicyNone:
      return @"No passcode required";
  }
}

@end

