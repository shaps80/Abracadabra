//
//  PasswordConfirmationField.h
//  FormValidation
//
//  Created by Shaps Mohsenin on 17/11/2014.
//  Copyright (c) 2014 Snippex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextField+SPXDataValidatorAdditions.h"
#import "SPXDataField.h"


/**
 *  This custom field demonstrates password (as well as confirmation) validation through composition
 *  This class will first validate each field, and then additionally validate itself if both fields are valid
 */
@interface SPXPasswordValidationField : NSObject <SPXDataField>


/**
 *  Initializes a new instance of this field
 *
 *  @param passwordField     The password field to be validated
 *  @param confirmationField The confirmation field to be validated
 *
 *  @return A new password validation field
 */
+ (instancetype)fieldForPasswordField:(UITextField <SPXDataField> *)passwordField confirmationField:(UITextField <SPXDataField> *)confirmationField;


@end
