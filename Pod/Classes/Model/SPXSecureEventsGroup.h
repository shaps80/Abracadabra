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

#import "SPXSecureEvent.h"


/**
 *  Defines a group of events. This can be used in your user interface for grouping events
 */
@interface SPXSecureEventsGroup : NSObject <NSCoding>


/**
 *  Returns a friendly name representing this group. Can be used in your user interface
 */
@property (nonatomic, copy, readonly) NSString *name;


/**
 *  Returns all events associated with this group
 */
@property (nonatomic, copy, readonly) NSArray *events;


/**
 *  Initializes a new group
 *
 *  @param name The friendly name associated with this group
 *
 *  @return A new instance of SPXSecureEventsGroup
 */
- (instancetype)initWithName:(NSString *)name;


/**
 *  Adds the specified event to this group
 *
 *  @param event The event to add
 */
- (void)addEvent:(SPXSecureEvent *)event;


/**
 *  Removes the specified event from this group
 *
 *  @param event The event to remove
 */
- (void)removeEvent:(SPXSecureEvent *)event;


/**
 *  Returns the event with the specified identifier if it exists, nil otherwise
 *
 *  @param identifier The identifier of the event to return
 *
 *  @return An existing event if it exists, nil otherwise
 */
- (SPXSecureEvent *)eventWithIdentifier:(NSString *)identifier;


@end

