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

#import "SPXSecurityInternal.h"
#import "SPXSecureEventsStore.h"
#import "SPXDefines.h"

#import <libkern/OSAtomic.h>
#import <mach-o/getsect.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>


extern NSString *_SPXSecurityIdentifier(spx_secure_entry *entry)
{
  return [NSString stringWithFormat:@"Abracadabra:%@:%@", *entry->group, *entry->name];
}

static SPXSecureEvent *_SPXSecureEventCreateWithEntry(NSString *identifier, spx_secure_entry *entry)
{
  return [[SPXSecureEvent alloc] initWithIdentifier:identifier name:*entry->name policy:(SPXSecurePolicy)entry->defaultPolicy];
}

@interface _SPXSecurityInternalLoader : NSObject
@end

@implementation _SPXSecurityInternalLoader

+ (void)load
{
  static uint32_t _eventsLoaded = 0;
  if (OSAtomicTestAndSetBarrier(1, &_eventsLoaded)) {
    return;
  }
  
#ifdef __LP64__
  typedef uint64_t spx_security_value;
  typedef struct section_64 spx_security_section;
#define spx_security_getsectbynamefromheader getsectbynamefromheader_64
#else
  typedef uint32_t spx_security_value;
  typedef struct section spx_security_section;
#define spx_security_getsectbynamefromheader getsectbynamefromheader
#endif
  
  SPXSecureEventsStore *store = [SPXSecureEventsStore sharedInstance];
  
  Dl_info info;
  dladdr(&_SPXSecurityIdentifier, &info);
  
  const spx_security_value mach_header = (spx_security_value)info.dli_fbase;
  const spx_security_section *section = spx_security_getsectbynamefromheader((void *)mach_header, _SPXSecuritySegmentName, _SPXSecuritySectionName);
  
  if (section == NULL) {
    return;
  }
  
  for (spx_security_value addr = section->offset; addr < section->offset + section->size; addr += sizeof(spx_secure_entry)) {
    spx_secure_entry *entry = (spx_secure_entry *)(mach_header + addr);
    
    SPXSecureEventsGroup *group = [store eventGroupWithName:*entry->group];

    if (!group) {
      group = [[SPXSecureEventsGroup alloc] initWithName:*entry->group];
      [store addEventGroup:group];
    }
    
    NSString *identifier = _SPXSecurityIdentifier(entry);
    SPXAssertTrueOrPerformAction(![group eventWithIdentifier:identifier], SPXLog(@"The identfier '%@' is already in use. This event will not be added.", identifier); continue);

    SPXSecureEvent *event = _SPXSecureEventCreateWithEntry(identifier, entry);
    
    if (event) {
      [group addEvent:event];
    }
  }
}

@end
