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

#import "SPXPoliciesViewController.h"
#import "SPXDefines.h"
#import "SPXSecureEventsStore.h"

@interface SPXPoliciesViewController ()
@property (nonatomic, strong) NSArray *policies;
@property (nonatomic, weak) SPXSecureEvent *event;
@end

@implementation SPXPoliciesViewController

- (instancetype)initWithEvent:(SPXSecureEvent *)event
{
  self = [super initWithStyle:UITableViewStyleGrouped];
  SPXAssertTrueOrReturnNil(self);
  _event = event;
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  NSString *timeout = [NSString stringWithFormat:@"Prompt when necessary"];
  self.policies = @
  [
   @"Always prompt",
   timeout,
   @"Confirm only",
   @"Disable",
  ];
  
  self.title = @"Select a Policy";
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
  return @"If you select 'Prompt when necessary', your passcode will only be required if your current session has expired.";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.policies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *const SPXSecurePolicyCellIdentifier = @"SPXSecurePolicyCellIdentifier";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SPXSecurePolicyCellIdentifier];
  
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SPXSecurePolicyCellIdentifier];
  }

  cell.accessoryType = (self.event.currentPolicy == indexPath.item) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
  
  if (self.event.currentPolicy > 2 && indexPath.item == 3) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
  }
  
  cell.textLabel.text = self.policies[indexPath.item];
 
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  self.event.currentPolicy = (SPXSecurePolicy)indexPath.item;
  [self.navigationController popViewControllerAnimated:YES];
}

@end
