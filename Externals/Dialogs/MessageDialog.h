/*
 *********************************************************************************
 *
 * Copyright (C) 2013-2014 T Dispatch Ltd
 *
 * See the LICENSE for terms and conditions of use, modification and distribution
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 *********************************************************************************
 *
 * @author Marcin Orlowski <marcin.orlowski@webnet.pl>
 *
 *********************************************************************************
 */

#import <UIKit/UIKit.h>

#import "CustomDialog.h"

typedef void (^MessageDialogConfirmationBlock)(NSString *message);

@interface MessageDialog : CustomDialog

+ (MessageDialog*) showError:(NSString *)message
                   withTitle:(NSString *)title;

+ (MessageDialog*) showMessage:(NSString *)message
                     withTitle:(NSString *)title;

+ (MessageDialog*) askConfirmation:(NSString *)message
                         withTitle:(NSString *)title
                 confirmationBlock:(MessageDialogConfirmationBlock)confirmationBlock;

+ (MessageDialog*) askConfirmationWithReason:(NSString *)message
                                   withTitle:(NSString *)title
                           confirmationBlock:(MessageDialogConfirmationBlock)confirmationBlock;


@end
