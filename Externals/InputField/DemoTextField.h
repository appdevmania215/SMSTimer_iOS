//
//  DemoTextField.h
//  MHTextField
//
//  Created by Mehfuz Hossain on 12/3/13.
//  Copyright (c) 2013 Mehfuz Hossain. All rights reserved.
//

#import <Foundation/Foundation.h>

// Application specific customization.
@interface DemoTextField : UITextField

@property (nonatomic, setter = setRequired:) BOOL required;
@property (nonatomic, setter = setEmailField:) BOOL isEmailField;

- (BOOL) validate;


@end
