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

#import "SPXSecureEventsGroup.h"


/**
 *  Defines a store for holding a reference to all groups and events used throughout your application
 */
@interface SPXSecureEventsStore : NSObject <NSCoding>


/**
 *  Returns the groups associated with this store. Each group contains 1 or more events
 */
@property (nonatomic, readonly) NSArray *eventGroups;


/**
 *  Returns a singleton instance of this class. This should be used at all times.
 *
 *  @return A singleton instance.
 */
+ (instancetype)sharedInstance;


/**
 *  Returns the group with the specified name
 *
 *  @param name The name of the group to return
 *
 *  @return An existing group if it exists, nil otherwise
 */
- (SPXSecureEventsGroup *)eventGroupWithName:(NSString *)name;


/**
 *  Adds the specified group to this store
 *
 *  @param group The group to add
 */
- (void)addEventGroup:(SPXSecureEventsGroup *)group;


/**
 *  Removes the specified group from this store
 *
 *  @param group The group to remove. This will also remove all associated events.
 */
- (void)removeEventGroup:(SPXSecureEventsGroup *)group;


/**
 *  Resets all events security policies to their defaults.
 *
 *  @note This method does not remove any groups of events.
 */
- (void)resetDefaults;


@end

