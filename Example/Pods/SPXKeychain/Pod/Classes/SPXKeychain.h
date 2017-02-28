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

@import Foundation;

/**
 *  Simple wrapper for using the keychain
 */
@interface SPXKeychain : NSObject


/**
 *  A default shared instance for convenience
 *
 *  @return A singleton instance
 */
+ (instancetype)sharedInstance;


/**
 *  Sets the object for the specified key and the given accessibility trait
 *
 *  @param object        The object to add to the keychain
 *  @param key           The key representing this object
 *  @param accessibility The accessibility trait for this accessing this object
 */
- (void)setObject:(id)object forKey:(NSString *)key accessibility:(CFTypeRef)accessibility;


/**
 *  Returns the object the specified key
 *
 *  @param key The key representing this object
 *
 *  @return The object for the specified key, nil if nothing found
 */
- (id)objectForKey:(NSString *)key;


/**
 *  Adds subscripting support for -setObject:forKey:
 *
 *  @param object The object to add to the keychain
 *  @param key    The key representing this object
 */
- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key;


/**
 *  Adds subscripting support for -objectForKey:
 *
 *  @param key The key representing the object to retrieve
 *
 *  @return The object for the specified key, nil if nothing found
 */
- (id)objectForKeyedSubscript:(id)key;


@end

