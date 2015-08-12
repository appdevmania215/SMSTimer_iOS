//
//  ContactUsViewController.h
//  TextTimer
//
//  Created by admin on 6/17/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class DemoTextField;
@class DemoTextView;
@class CustomButton;

@interface ContactUsViewController : UIViewController<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet DemoTextField *tfSubject;
@property (weak, nonatomic) IBOutlet DemoTextField *tfReplyEmail;
@property (weak, nonatomic) IBOutlet DemoTextView *tvMessage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet CustomButton *btnSend;

@end
