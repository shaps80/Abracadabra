#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SPXAssertionDefines.h"
#import "SPXAssertionsInternal.h"
#import "SPXDefines.h"
#import "SPXDefinesCommon.h"
#import "SPXDescriptionDefines.h"
#import "SPXDescriptionInternal.h"
#import "SPXEncodingDefines.h"
#import "SPXEncodingInternals.h"
#import "SPXLoggingDefines.h"
#import "SPXLoggingInternal.h"

FOUNDATION_EXPORT double SPXDefinesVersionNumber;
FOUNDATION_EXPORT const unsigned char SPXDefinesVersionString[];

