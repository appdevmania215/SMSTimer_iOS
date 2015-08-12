//
//  Constants.h
//  TextTime
//
//  Created by admin on 6/9/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <Foundation/Foundation.h>

#define k_KEYBOARD_OFFSET 210.0f

static CGFloat const kRecepientNameTextFontSize = 12;
static CGFloat const kRecepientPhoneNumberTextFontSize = 10;

#pragma marks - Contact Email Address
extern NSString *const ContactEmailAddress;

#pragma marsk - Share Url
extern NSString *const ShareUrl;

#pragma marks Schedule Tab

extern NSString *const SetScheduleTabNotification;
extern NSString *const SetScheduleTabViewNotification;
extern NSString *const TAB_NUMBER;
extern int const ALL;
extern int const SCHEDULED;
extern int const SENT;

#pragma marks Compose
extern NSString *const ComposeEditSchedule;
extern NSString *const ComposeTrashSchedule;
extern NSString *const ComposeDatePickerShow;
extern NSString *const ComposeTimePickerShow;
extern NSString *const ComposeContactPickerShow;
extern NSString *const ComposeUpdateRecepients;

#pragma marks Schedule state
extern NSString *const ScheduleStandBy;
extern NSString *const ScheduleSent;
extern NSString *const ScheduleSendSMSMessage;

@interface Constants : NSObject

@end
