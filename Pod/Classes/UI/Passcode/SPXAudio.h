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

@import Foundation;
@import AudioToolbox;


#if TARGET_OS_IPHONE

typedef enum
{
  SPXAudioTypeVibrate             = kSystemSoundID_Vibrate,
  SPXAudioTypeNewMail             = 1000,
  SPXAudioTypeMailSent            = 1001,
  SPXAudioTypeNewMessage          = 1002,
  SPXAudioTypeReminder            = 1005,
  SPXAudioTypeLowPower            = 1006,
  SPXAudioTypeTweetSent           = 1016,
  SPXAudioTypeLock                = 1100,
  SPXAudioTypeUnlock              = 1101,
  SPXAudioTypeCharging            = 1106,
  SPXAudioTypeShutter             = 1108,
} SPXAudioType;

#endif

/**
 Provides convenience wrapper for dealing with system and custom sounds.
 This class also has built in caching and UIImage style convenience for loading a sound via its name (with or without extension for mp3 and wav types)
 The class also cleans up any caching if the -didReceiveMemoryWarnings is called by the system.
 */
@interface SPXAudio : NSObject

/**
 @abstract      Attempts to play the sound file with the specified name
 @param         name The filename of the sound file to be played
 @discussion    You don't have to specify an extension if the file is an mp3 or wav file, otherwise you should
 */
+ (void)playAudioNamed:(NSString *)name;

#if TARGET_OS_IPHONE
+ (void)playSystemAudioType:(SPXAudioType)type;
+ (void)vibrate;
#endif

@end
