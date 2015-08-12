//
//  ComposeViewController.m
//  TextTimer
//
//  Created by admin on 6/18/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "ComposeViewController.h"
#import "ComposeActionTableViewCell.h"
#import "ComposeScheduleDateTableViewCell.h"
#import "ComposeScheduleTimeTableViewCell.h"
#import "ComposeRecepientsTableViewCell.h"
#import "ComposeMessageTableViewCell.h"
#import "RecepientsContainerView.h"
#import "../Constants.h"
#import "../Schedule/Contact.h"
#import "../Schedule/Contact.h"
#import "../Schedule/Schedule.h"
#import "../../Externals/InputField/DemoTextView.h"
#import "ScheduleViewController.h"

#import <AddressBook/AddressBook.h>

@interface ComposeViewController ()

@end

@implementation ComposeViewController

@synthesize datetimePicker;
@synthesize lblScheduleDate;
@synthesize lblScheduleTime;
@synthesize recepientsContainerView;
@synthesize tvMessage;
@synthesize isEdit;
@synthesize buttonContainerView;
@synthesize scheduleViewController;


- (void) setState:(Schedule*)schedule {
    mSchedule = schedule;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNotificationManager];
    [self.btnSend setCorner:YES];
    [datetimePicker setHidden:YES];
    datetimePicker.backgroundColor = [UIColor grayColor];
    [datetimePicker addTarget:self action:@selector(changeDateTime) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.tableView addGestureRecognizer:tap];

    if ( mContactList == nil ) {
        mContactList = [[NSMutableArray alloc] init];
    }
    
    if ( mSchedule == nil ) {
        isEdit = YES;
        isSetDateTime = NO;
        [buttonContainerView setHidden:NO];
        
    }
    else {
        isEdit = NO;
        isSetDateTime = YES;
        [buttonContainerView setHidden:YES];
        NSArray *contacts = [mSchedule getRecepients];
        for ( int j = 0; j < [contacts count]; j++ ) {
            [mContactList addObject:contacts[j]];
        }
        NSDate *date = [mSchedule getReservationDateTime];
        [datetimePicker setDate:date];
    }
} 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [recepientsContainerView reloadRecepients];
//    [self.tableView reloadData];
}

#pragma mark - Button Actions
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)sendSchedule:(id)sender {
    if ( [mContactList count] == 0 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Compose Error" message:@"There are no selected recepients." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else if ( [tvMessage validate] == NO ) {
    }
    else if ( [self isValidDateTime] == YES ) {
        [self addSchedule];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Compose Error" message:@"Datetime is invalid." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (BOOL) isValidDateTime {
    NSDate *curDateTime = [NSDate new];
    if ( isSetDateTime == NO ) {
        NSDate *datetime = [[NSDate alloc] initWithTimeIntervalSince1970:[curDateTime timeIntervalSince1970] + 3];
        [datetimePicker setDate:datetime];
        return YES;
    }
    NSDate *selDateTime = [datetimePicker date];
    if ( round([curDateTime timeIntervalSince1970] / 60) > round([selDateTime timeIntervalSince1970]/60) )
        return NO;
    return YES;
}
- (BOOL)isUpdatableDateTime {
    NSDate *curDateTime = [NSDate new];
    NSDate *selDateTime = [datetimePicker date];
    if ( [curDateTime timeIntervalSince1970] > [selDateTime timeIntervalSince1970] )
        return YES;
    return NO;
}
- (void) addSchedule {
	if ( mSchedule == nil ) {
        mSchedule = [[Schedule alloc] init];
        [mSchedule setMessage:tvMessage.text];
        [mSchedule setReservationDateTime:[datetimePicker date]];
        [mSchedule setRecepients:mContactList];
        [mSchedule setState:NO];
        [scheduleViewController addSchedule:mSchedule isUpdate:YES];
    }
    else {
        [mSchedule setMessage:tvMessage.text];
        [mSchedule setReservationDateTime:[datetimePicker date]];
        [mSchedule setRecepients:mContactList];
        if ( [mSchedule isSent] == YES ) {
            [scheduleViewController changeSchedule:mSchedule];
        }
        else {
            [scheduleViewController updateSchedule:mSchedule isUpdate:YES];
            [self cancelAlarm:mSchedule];
        }
    }
    [self setAlarm:mSchedule];
    [scheduleViewController refresh];
}

- (void) removeSchedule {
    if ( mSchedule != nil ) {
        [self cancelAlarm:mSchedule];
        [scheduleViewController removeSchedule:mSchedule isUpdate:YES];
        [scheduleViewController refresh];
    }
}

- (void) cancelAlarm:(Schedule*)schedule {
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    
    for ( int i = 0; i < [eventArray count]; i++ ) {
        UILocalNotification *oneEvent = [eventArray objectAtIndex:i];
        NSDictionary *userInfo = oneEvent.userInfo;
        NSString *notificationID = [NSString stringWithFormat:@"%@", [userInfo valueForKey:@"shceudleID"]];
        NSString *scheduleID = [NSString stringWithFormat:@"%@", [schedule getScheduleId]];
        if ( [notificationID isEqualToString:scheduleID] ) {
            [app cancelLocalNotification:oneEvent];
            break;
        }
    }
}

- (void) setAlarm:(Schedule*)schedule  {
    NSDate *pickerDate = [datetimePicker date];
    
    NSString *phoneNumbers = [NSString stringWithFormat:@"%@", [schedule getPhoneNumbers]];
    NSString *scheduleID = [NSString stringWithFormat:@"%@", [schedule getScheduleId]];
    NSString *message = tvMessage.text;

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:phoneNumbers forKey:@"phoneNumbers"];
    [userInfo setValue:message forKey:@"message"];
    [userInfo setValue:scheduleID forKey:@"scheduleID"];
    
    // Schedule the notification
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = pickerDate;
    localNotification.alertBody = @"It is time to send SMS Message";
    localNotification.alertAction = @"Show me the item";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = 0;
    localNotification.userInfo = userInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    // Dismiss the view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - ComposeActionTableViewCell

- (void) editScheduleInCell:(ComposeActionTableViewCell *)cell {
    [self setEditable:YES];
    [buttonContainerView setHidden:NO];
    [recepientsContainerView setEditable:YES];
    [recepientsContainerView reloadRecepients];
    [self.tableView reloadData];
}

- (void)trashScheduleInCell:(ComposeActionTableViewCell *)cell
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Remove Schedule" message:@"Are you sure to delete this schedule." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

#pragma mark - Notification

- (void) setNotificationManager {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:ComposeEditSchedule object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:ComposeTrashSchedule object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:ComposeDatePickerShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:ComposeTimePickerShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:ComposeContactPickerShow object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:ComposeUpdateRecepients object:nil];
}

- (void) removeNotificationManager {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:ComposeTrashSchedule object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:ComposeEditSchedule object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ComposeDatePickerShow object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ComposeTimePickerShow object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ComposeContactPickerShow object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ComposeUpdateRecepients object:nil];
}

- (void) receiveNotification:(NSNotification *)notification {
	if ( [[notification name] isEqualToString:ComposeDatePickerShow] ) {
        [datetimePicker setDatePickerMode:UIDatePickerModeDate];
        NSDate *date = [NSDate new];
        [datetimePicker setMinimumDate:date];
        if ( [self isUpdatableDateTime] == YES ) {
            NSDateFormatter *df = [[NSDateFormatter alloc]init];
            df.dateStyle = NSDateFormatterLongStyle;
            lblScheduleDate.text = [df stringFromDate:date];
        }
        [datetimePicker setHidden:NO];
    }
    else if ( [[notification name] isEqualToString:ComposeTimePickerShow] ) {
        [datetimePicker setDatePickerMode:UIDatePickerModeTime];
        NSDate *date = [NSDate new];
        [datetimePicker setMinimumDate:date];
        if ( [self isUpdatableDateTime] == YES ) {
            date = [[NSDate alloc] initWithTimeIntervalSince1970:[date timeIntervalSince1970] + 60];
            [datetimePicker setDate:date];
            NSDateFormatter *df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"hh:mm aa"];
            lblScheduleTime.text = [df stringFromDate:date];
        }
        [datetimePicker setHidden:NO];
    }
    else if ( [[notification name] isEqualToString:ComposeContactPickerShow] ) {
        ABPeoplePickerNavigationController *peoplePickerController = [[ABPeoplePickerNavigationController alloc] init];
        peoplePickerController.peoplePickerDelegate = self;
        [peoplePickerController.navigationBar setTintColor:[UIColor whiteColor]];
        [self presentViewController:peoplePickerController animated:YES completion:nil];
    }
    else if ( [[notification name] isEqualToString:ComposeUpdateRecepients] ) {
        [self.tableView reloadData];
    }
}

-(void)dealloc {
    [self removeNotificationManager];
    
    mSchedule = nil;
    mContactList = nil;
    mActionCell = nil;
    mScheduleDateCell = nil;
    mScheduleTimeCell = nil;
    mRecepientsCell = nil;
    mMessageCell = nil;
}

#pragma mark - UIAlert Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 1 ) {
        [self removeSchedule];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    long row = [indexPath row];
    if ( row == 0 ) {
        if ( mActionCell )
            return mActionCell;
        
        ComposeActionTableViewCell *cell = (ComposeActionTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"composeActionTableCell"];
        
        mActionCell = cell;
        cell.delegate = self;
        
        return cell;
    }
    else if ( row == 1 ) {
        if ( mScheduleDateCell ) {
            [mScheduleDateCell setEditable:isEdit];
            return mScheduleDateCell;
        }
        
        ComposeScheduleDateTableViewCell *cell = (ComposeScheduleDateTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"composeScheduleDateTableCell"];
        [cell setEditable:isEdit];
        lblScheduleDate = cell.lblScheduleDate;

        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        df.dateStyle = NSDateFormatterLongStyle;
        NSDate *date;
        if ( mSchedule != nil ) {
            date = [mSchedule getReservationDateTime];
        }
        else {
        	date = [NSDate new];
        }
        lblScheduleDate.text = [df stringFromDate:date];
        
        mScheduleDateCell = cell;

        return cell;
    }
    else if ( row == 2 ) {
        if ( mScheduleTimeCell ) {
            [mScheduleTimeCell setEditable:isEdit];
            return mScheduleTimeCell;
        }
        
        ComposeScheduleTimeTableViewCell *cell = (ComposeScheduleTimeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"composeScheduleTimeTableCell"];
        [cell setEditable:isEdit];
        lblScheduleTime = cell.lblScheduleTime;
        
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"hh:mm aa"];
        NSDate *date;
        if ( mSchedule != nil ) {
            date = [mSchedule getReservationDateTime];
        }
        else {
            date = [[NSDate alloc] initWithTimeIntervalSince1970:[[NSDate new] timeIntervalSince1970] + 60];
        }
        
        lblScheduleTime.text = [df stringFromDate:date];

        mScheduleTimeCell = cell;
        
        return cell;
    }
    else if ( row == 3 ) {
        if ( mRecepientsCell ) {
            [mRecepientsCell setEditable:isEdit];
            return mRecepientsCell;
        }
        
        ComposeRecepientsTableViewCell *cell = (ComposeRecepientsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"composeRecepientsTableCell"];
        [cell setEditable:isEdit];
        recepientsContainerView = cell.recepientsView;
        [recepientsContainerView setEditable:isEdit];
        [recepientsContainerView setParentViewController:self];
        
        if ( mContactList != nil && [mContactList count] > 0 ) {
            for ( int i = 0; i < [mContactList count]; i++ ) {
	            [recepientsContainerView addRecepient:(Contact*)mContactList[i]];
            }
        }
        
        mRecepientsCell = cell;
        
        return cell;
    }
    else if ( row == 4 ) {
        if ( mMessageCell ) {
            [mMessageCell setEditable:isEdit];
            return mMessageCell;
        }
        
        ComposeMessageTableViewCell *cell = (ComposeMessageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"composeMessageTableCell"];
        [cell setEditable:isEdit];
        tvMessage = cell.tvMessage;
        if ( mSchedule != nil )
            tvMessage.text = [mSchedule getMessage];
        else
            tvMessage.text = @"";
        
        mMessageCell = cell;
        
        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    long row = [indexPath row];
    
    if ( row == 0 ) {
        if ( isEdit == YES )
            return 0;
        else
            return 50;
    }
    else if ( row >= 1 && row <= 2 ) {
    	return 90;
    }
    else if ( row == 3 ) {
        if ( recepientsContainerView == nil ) {
            ComposeRecepientsTableViewCell *cell = (ComposeRecepientsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"composeRecepientsTableCell"];
            [cell setEditable:isEdit];
            recepientsContainerView = cell.recepientsView;
            [recepientsContainerView setEditable:isEdit];
            [recepientsContainerView setParentViewController:self];
            
            if ( mContactList != nil && [mContactList count] > 0 ) {
                for ( int i = 0; i < [mContactList count]; i++ ) {
                    [recepientsContainerView addRecepient:(Contact*)mContactList[i]];
                }
            }
            
            mRecepientsCell = cell;
        }
        return [recepientsContainerView getSize] + 45.0f;
    }
    else if ( row == 4 ) {
        return 150;
    }
    return 0;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [datetimePicker setHidden:YES];
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [datetimePicker setHidden:YES];
}

#pragma mark - datepicker

-(void)changeDateTime
{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    if ( datetimePicker.datePickerMode == UIDatePickerModeDate ) {
        df.dateStyle = NSDateFormatterLongStyle;
        lblScheduleDate.text = [df stringFromDate:datetimePicker.date];
    }
    else {
        [df setDateFormat:@"hh:mm aa"];
        lblScheduleTime.text = [df stringFromDate:datetimePicker.date];
    }
    isSetDateTime = YES;
}

#pragma mark - Touch Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ( touch.view != datetimePicker) {
        [datetimePicker setHidden:YES];
    }
}

-(void)handleTap:(UITapGestureRecognizer *)recognizer {
    [datetimePicker setHidden:YES];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {

    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex phoneCount = ABMultiValueGetCount(phones);
    if ( phoneCount > 1 || phoneCount == 0 )
        return YES;
    
    NSString *contactID = [NSString stringWithFormat:@"%d", ABRecordGetRecordID(person)];
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if ( firstName == nil )
        firstName = @"";
    if ( lastName == nil )
        lastName = @"";
    
    Contact *contact = [[Contact alloc] init];
    [contact setContactId:contactID];
    [contact setContactName:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
    for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
    {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
        CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phones, j);
        NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
        NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
        CFRelease(phoneNumberRef);
        CFRelease(locLabel);
        [contact addPhoneNumber:phoneLabel phoneNumber:phoneNumber];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self addRecepient:contact];
    
    return NO;
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    if (property == kABPersonPhoneProperty) {
        NSString *contactID = [NSString stringWithFormat:@"%d", ABRecordGetRecordID(person)];
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        if ( firstName == nil )
            firstName = @"";
        if ( lastName == nil )
            lastName = @"";
        
        ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
        CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phoneProperty, identifier);
        NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
        NSString *phoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneProperty,identifier);
        Contact *contact = [[Contact alloc] init];
        [contact setContactId:contactID];
        [contact setContactName:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
        [contact addPhoneNumber:phoneLabel phoneNumber:phoneNumber];
        CFRelease(locLabel);
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [self addRecepient:contact];
    }
    
    return NO;
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    if (property == kABPersonPhoneProperty) {
        
        
        NSString *contactID = [NSString stringWithFormat:@"%d", ABRecordGetRecordID(person)];        
        NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *lastName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        if ( firstName == nil )
            firstName = @"";
        if ( lastName == nil )
            lastName = @"";
        
        
        ABMultiValueRef phoneProperty = ABRecordCopyValue(person,property);
        CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(phoneProperty, identifier);
        NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
        NSString *phoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneProperty,identifier);
        Contact *contact = [[Contact alloc] init];
        [contact setContactId:contactID];
        [contact setContactName:[NSString stringWithFormat:@"%@ %@", firstName, lastName]];
        [contact addPhoneNumber:phoneLabel phoneNumber:phoneNumber];
        CFRelease(locLabel);
        [self dismissViewControllerAnimated:YES completion:nil];
        
        [self addRecepient:contact];
    }
    
}

-(void) addRecepient:(Contact*)contact {
    for ( int i = 0; i < [mContactList count]; i++ ) {
        Contact *oldContact = (Contact*)mContactList[i];
        if ( [[oldContact getContactId] isEqualToString:[contact getContactId]] )
            return;
    }
    [mContactList addObject:contact];
    [recepientsContainerView addRecepient:contact];
    [self.tableView reloadData];
}

- (void) removeRecepient:(Contact*)contact {
    [mContactList removeObject:contact];
}


@end
