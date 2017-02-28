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

#import "SPXPasswordValidationField.h"
#import "SPXDataField.h"
#import "UITextField+SPXDataValidatorAdditions.h"
#import "UITextView+SPXDataValidatorAdditions.h"
#import "SPXFormValidator.h"
#import "SPXDataValidator.h"
#import "SPXBlockDataValidator.h"
#import "SPXCompoundDataValidator.h"
#import "SPXNonEmptyDataValidator.h"
#import "SPXRegexDataValidator.h"

FOUNDATION_EXPORT double SPXDataValidatorsVersionNumber;
FOUNDATION_EXPORT const unsigned char SPXDataValidatorsVersionString[];

