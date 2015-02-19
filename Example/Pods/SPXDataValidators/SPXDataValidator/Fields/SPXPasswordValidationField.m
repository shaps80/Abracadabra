//
//  PasswordConfirmationField.m
//  FormValidation
//
//  Created by Shaps Mohsenin on 17/11/2014.
//  Copyright (c) 2014 Snippex. All rights reserved.
//

#import <objc/runtime.h>
#import "SPXPasswordValidationField.h"

@interface SPXPasswordValidationField ()
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextField *confirmationField;
@end

@implementation SPXPasswordValidationField

- (void)setDataValidator:(id<SPXDataValidator>)validator
{
  @synchronized(self) {
    objc_setAssociatedObject(self, @selector(dataValidator), validator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
}

- (id<SPXDataValidator>)dataValidator
{
  return objc_getAssociatedObject(self, @selector(dataValidator));
}

+ (instancetype)fieldForPasswordField:(UITextField *)passwordField confirmationField:(UITextField *)confirmationField
{
  SPXPasswordValidationField *field = [SPXPasswordValidationField new];
  field.passwordField = passwordField;
  field.confirmationField = confirmationField;
  return field;
}

- (void)applyValidator:(id<SPXDataValidator>)validator
{
  @synchronized(validator) {
    self.dataValidator = validator;
  }
}

- (BOOL)validateWithError:(out NSError *__autoreleasing *)error
{
  if ([self.passwordField validateWithError:error] && [self.confirmationField validateWithError:error]) {
    if (![self.passwordField.text isEqualToString:self.confirmationField.text]) {
      if (error) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"Passwords don't match" };
        *error = [NSError errorWithDomain:@"uk.co.snippex.validation" code:-1 userInfo:userInfo];
      }
      
      return NO;
    }
    
    return YES;
  }
  
  return NO;
}

@end
