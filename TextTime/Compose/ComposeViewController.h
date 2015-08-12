//
//  ComposeViewController.h
//  TextTimer
//
//  Created by admin on 6/18/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomButton.h"
#import <AddressBookUI/AddressBookUI.h>
#import "ComposeActionTableViewCell.h"

@class Contact;
@class RecepientsContainerView;
@class Schedule;
@class DemoTextView;
@class ComposeActionTableViewCell;
@class ComposeScheduleDateTableViewCell;
@class ComposeScheduleTimeTableViewCell;
@class ComposeRecepientsTableViewCell;
@class ComposeMessageTableViewCell;
@class ScheduleViewController;

@interface ComposeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, ABPeoplePickerNavigationControllerDelegate, UIAlertViewDelegate, ComposeActionTableViewCellDelegate> {
    Schedule *mSchedule;
    NSMutableArray *mContactList;
    BOOL isSetDateTime;
    
    ComposeActionTableViewCell *mActionCell;
    ComposeScheduleDateTableViewCell *mScheduleDateCell;
    ComposeScheduleTimeTableViewCell *mScheduleTimeCell;
    ComposeRecepientsTableViewCell *mRecepientsCell;
    ComposeMessageTableViewCell *mMessageCell;
}

//@property (weak, nonatomic) IBOutlet ComposeActionTableViewCell *actionCell;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CustomButton *btnSend;
@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datetimePicker;

@property (strong, nonatomic) RecepientsContainerView *recepientsContainerView;
@property (strong, nonatomic) UILabel *lblScheduleDate;
@property (strong, nonatomic) UILabel *lblScheduleTime;
@property (strong, nonatomic) DemoTextView *tvMessage;

@property (nonatomic, setter = setEditable:) BOOL isEdit;
@property (nonatomic, setter = setScheduleViewController:) ScheduleViewController *scheduleViewController;

- (void) setState:(Schedule*)schedule;
- (void) removeRecepient:(Contact*)contact;
- (void) removeSchedule;
- (void) cancelAlarm:(Schedule*)schedule;
- (void) setAlarm:(Schedule*)schedule;

@end
