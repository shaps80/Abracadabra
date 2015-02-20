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

#import "SPXKeychain.h"

#if __has_feature(objc_arc)
#define SPX_ID __bridge id
#define SPX_DICTIONARY_REF __bridge CFDictionaryRef
#else
#define SPX_ID id
#define SPX_DICTIONARY_REF CFDictionaryRef
#endif

@implementation SPXKeychain

+ (instancetype)sharedInstance
{
  static SPXKeychain *_sharedInstance = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

#pragma mark - Core

- (void)setObject:(id)object forKey:(NSString *)key accessibility:(CFTypeRef)accessibility
{
  NSParameterAssert(key.length);
  
  NSString *storeKey = [self keyWithPrefixForKey:key];
  
  if (!object) { // deleting
    NSMutableDictionary *query = [self query];
    [query setObject:storeKey forKey:(SPX_ID)kSecAttrService];
    SecItemDelete((SPX_DICTIONARY_REF)query);
    return;
  }
  
  OSStatus status;
  NSMutableDictionary *dict = [self service];
  [dict setObject:storeKey forKey:(SPX_ID)kSecAttrService];
  
#if TARGET_OS_IPHONE
  [dict setObject:(SPX_ID)(accessibility) forKey:(SPX_ID)kSecAttrAccessible];
#endif
  
  Class archiverClass = nil;
#if TARGET_OS_IPHONE
  archiverClass = NSKeyedArchiver.class;
#else
  archiverClass = NSArchiver.class;
#endif
  
  id storeObject = [archiverClass archivedDataWithRootObject:object];
  [dict setObject:storeObject forKey:(SPX_ID)kSecValueData];
  status = SecItemAdd((SPX_DICTIONARY_REF) dict, NULL);
  
  if (status == errSecDuplicateItem) {
    NSMutableDictionary *query = [self query];
    
    [query setObject:storeKey forKey:(SPX_ID)kSecAttrService];
    status = SecItemDelete((SPX_DICTIONARY_REF)query);
    
    if (status == errSecSuccess) {
      SecItemAdd((SPX_DICTIONARY_REF) dict, NULL);
    }
  }
}

- (void)setObject:(id)object forKey:(NSString *)key
{
  CFTypeRef accessibility = kSecAttrAccessibleWhenUnlocked;
  
  if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
    accessibility = kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
  }
  
  [self setObject:object forKey:key accessibility:accessibility];
}

- (id)objectForKey:(NSString *)key
{
  NSString *storeKey = [self keyWithPrefixForKey:key];
  
  NSMutableDictionary *query = [self query];
  [query setObject:storeKey forKey:(SPX_ID)kSecAttrService];
  
  CFDataRef data = nil;
	SecItemCopyMatching((SPX_DICTIONARY_REF)query, (CFTypeRef *)&data);
  
  if (!data) {
    return nil;
  }
  
  Class archiverClass = nil;
#if TARGET_OS_IPHONE
  archiverClass = NSKeyedUnarchiver.class;
#else
  archiverClass = NSUnarchiver.class;
#endif
  
  id storeObject = [archiverClass unarchiveObjectWithData:
#if __has_feature(objc_arc)
  (__bridge_transfer NSData *)data
#else
  (NSData *)data
#endif
  ];
  
#if !__has_feature(objc_arc)
  CFRelease(data);
#endif
  
  return storeObject;
}

- (void)removeObjectForKey:(NSString *)key
{
  [self setObject:nil forKey:key];
}

#pragma mark - Subscripting

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key
{
  [self setObject:obj forKey:key];
}

- (id)objectForKeyedSubscript:(id)key
{
  return [self objectForKey:key];
}

#pragma mark - Helpers

- (NSString *)keyWithPrefixForKey:(NSString *)key
{
  // TODO: This will cause issues when sharing across extension!!
  return [NSString stringWithFormat:@"%@.%@", [[NSBundle mainBundle] bundleIdentifier], key];
}

- (NSMutableDictionary *)service
{
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  [dict setObject:(SPX_ID)kSecClassGenericPassword forKey:(SPX_ID)kSecClass];
  return dict;
}

- (NSMutableDictionary *)query
{
  NSMutableDictionary *query = [NSMutableDictionary dictionary];
  
  [query setObject:(SPX_ID)kSecClassGenericPassword forKey:(SPX_ID)kSecClass];
  [query setObject:(SPX_ID)kCFBooleanTrue forKey:(SPX_ID) kSecReturnData];
  
  return query;
}

@end
