/*
 Copyright (c) 2013 Snippex. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY Snippex `AS IS' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 EVENT SHALL Snippex OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SPXAudio.h"
#import "SPXDefines.h"
#import <AudioToolbox/AudioToolbox.h>

@interface SPXAudio ()
@property (nonatomic, strong) NSMutableDictionary *preloadedAudio;
@end

@implementation SPXAudio

- (id)init
{
  self = [super init];
  
  if (self)
  {
#if TARGET_OS_IPHONE
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
  }
  
  return self;
}

#if TARGET_OS_IPHONE
- (void)didReceiveMemoryWarning:(NSNotification *)note
{
  for (NSNumber *sound in self.preloadedAudio.allValues)
    AudioServicesDisposeSystemSoundID([sound intValue]);
}
#endif

+(instancetype)sharedInstance
{
  static SPXAudio *_sharedInstance = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (NSString *)pathForAudioNamed:(NSString *)name
{
  NSString *filename = [name stringByDeletingPathExtension];
  NSString *extension = [name pathExtension];
  NSURL *url = nil;
  
  // if we have the filename and extension
  if (extension) url = [[NSBundle mainBundle] URLForResource:filename withExtension:extension];
  if (!url) url = [[NSBundle mainBundle] URLForResource:filename withExtension:@"wav"];
  if (!url) url = [[NSBundle mainBundle] URLForResource:filename withExtension:@"mp3"];
  
  return url.path;
}

- (NSMutableDictionary *)preloadedAudio
{
  return _preloadedAudio ?: (_preloadedAudio = [NSMutableDictionary new]);
}

- (SystemSoundID)preloadCustomAudioNamed:(NSString *)name
{
  SystemSoundID soundID = 0;
  NSURL *url = [NSURL fileURLWithPath:[self pathForAudioNamed:name]];
  if (!url) return 0;
  AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
  self.preloadedAudio[name] = @(soundID);
  return soundID;
}

- (void)playCustomAudioNamed:(NSString *)name
{
  SystemSoundID soundID = (SystemSoundID)[self.preloadedAudio[name] integerValue];
  if (!soundID) soundID = [self preloadCustomAudioNamed:name];
  if (!soundID) return;
  AudioServicesPlaySystemSound(soundID);
}

- (void)playSystemAudio:(SystemSoundID)soundID
{
  AudioServicesPlaySystemSound(soundID);
}

#pragma mark - Public API

+ (void)playAudioNamed:(NSString *)name
{
  [[SPXAudio sharedInstance] playCustomAudioNamed:name];
}

#if TARGET_OS_IPHONE

+ (void)playSystemAudioType:(SPXAudioType)type
{
  [[SPXAudio sharedInstance] playSystemAudio:type];
}

+ (void)vibrate
{
  [[SPXAudio sharedInstance] playSystemAudio:SPXAudioTypeVibrate];
}

#endif

@end
