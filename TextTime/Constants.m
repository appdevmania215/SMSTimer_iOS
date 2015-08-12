//
//  Constants.m
//  TextTime
//
//  Created by admin on 6/9/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "Constants.h"

#pragma marks - Contact Email Address
NSString *const ContactEmailAddress = @"info@abmobileapps.com";

#pragma marsk - Share Url
NSString *const ShareUrl = @"http://abmobileapps.com/apps/qrcodes/texttimer/index.html";

#pragma marks - Schedule Tab

NSString *const SetScheduleTabNotification = @"SetTab";
NSString *const SetScheduleTabViewNotification = @"SetTabView";
NSString *const TAB_NUMBER = @"TabNumber";
int const ALL = 100;
int const SCHEDULED = 101;
int const SENT = 102;

#pragma marks Compose
NSString *const ComposeEditSchedule = @"ComposeEditSchedule";
NSString *const ComposeTrashSchedule = @"ComposeTrashSchedule";
NSString *const ComposeDatePickerShow = @"ComposeDatePickerShow";
NSString *const ComposeTimePickerShow = @"ComposeTimePickerShow";
NSString *const ComposeContactPickerShow = @"ComposeContactPickerShow";
NSString *const ComposeUpdateRecepients = @"ComposeUpdateRecepients";

#pragma marks Schedule state
NSString *const ScheduleStandBy = @"standby";
NSString *const ScheduleSent = @"sent";
NSString *const ScheduleSendSMSMessage = @"SendSMSMessage";

@implementation Constants

@end
