//
//  ScheduleViewController.m
//  TextTime
//
//  Created by admin on 6/10/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ScheduleTableViewController.h"
#import "ViewController.h"
#import "ComposeViewController.h"
#import "Constants.h"
#import "../ViewController.h"
#import "TabView.h"
#import "CustomButton.h"
#import "SQLiteManager.h"
#import "TextTimerDBManager.h"
#import "Schedule.h"
#import "../AppDelegate.h"

@interface ScheduleViewController () {
    BOOL isShowSMSMessageViewController;
}

@property (nonatomic, strong) NSMutableArray *scheduleListViewControllers;

@end

@implementation ScheduleViewController

@synthesize ContainerView;
@synthesize scheduleListViewControllers;

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
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[self.ContainerView bounds]];
    
    ScheduleTableViewController *allViewController = [self viewControllerAtIndex:0];
    ScheduleTableViewController *scheduledViewController = [self viewControllerAtIndex:1];
    ScheduleTableViewController *sentViewController = [self viewControllerAtIndex:2];
    
    [allViewController setParentScheduleViewController:self];
    [scheduledViewController setParentScheduleViewController:self];
    [sentViewController setParentScheduleViewController:self];
    
    [allViewController setType:ALL];
    [scheduledViewController setType:SCHEDULED];
    [sentViewController setType:SENT];
    
    [[allViewController scheduleList] addObject:[scheduledViewController scheduleList]];
    [[allViewController scheduleList] addObject:[sentViewController scheduleList]];
    
    scheduleListViewControllers = [NSMutableArray arrayWithObjects:allViewController, scheduledViewController, sentViewController, nil];
    
    [self.pageController setViewControllers:[NSArray arrayWithObject:scheduledViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [self.ContainerView addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
//    [self jumpToTab:1];
    currentPage = 1;
    [self setNotificationManager];
    
    [_btnCompose setCorner:YES];
    isShowSMSMessageViewController = NO;
    
    NSArray *scheduledList = [scheduledViewController scheduleList];
    if ( scheduledList != nil ) {
        for ( int i = 0; i < [scheduledList count]; i++ ) {
            Schedule *schedule = scheduledList[i];
            if ( schedule.isSent == NO && [schedule isPassed] == YES ) {
                NSString *phoneNumbers = [NSString stringWithFormat:@"%@", [schedule getPhoneNumbers]];
                NSString *scheduleID = [NSString stringWithFormat:@"%@", [schedule getScheduleId]];
                NSString *message = [NSString stringWithFormat:@"%@", [schedule getMessage]];
                
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                [userInfo setValue:phoneNumbers forKey:@"phoneNumbers"];
                [userInfo setValue:message forKey:@"message"];
                [userInfo setValue:scheduleID forKey:@"scheduleID"];
                
                AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                [appDelegate addNotification:userInfo];
            }
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] postNotificationName:ScheduleSendSMSMessage object:self];
}

#pragma  mark - Button Actions
- (IBAction)composeButton:(id)sender {
    ComposeViewController *composeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ComposeViewController"];
    [composeViewController setEditable:YES];
    [composeViewController setState:nil];
    [composeViewController setScheduleViewController:self];
    [((ViewController*)[self parentViewController]).navigationController pushViewController:composeViewController animated:YES];
}

#pragma mark - Notification

- (void) setNotificationManager {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:SetScheduleTabNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:ScheduleSendSMSMessage object:nil];
}

- (void) receiveNotification:(NSNotification *)notification {
    if ( [[notification name] isEqualToString:SetScheduleTabNotification] ) {
        NSDictionary *data = [notification userInfo];
        if ( data != nil ) {
            int number = [[data objectForKey:TAB_NUMBER] intValue];
            [self jumpToTab:number];
        }
    }
    else if ( [[notification name] isEqualToString:ScheduleSendSMSMessage] ) {
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        notificationInfo = appDelegate.notificationInfo;
        if ( notificationInfo != nil && [notificationInfo count] > 0 ) {
            if ( isShowSMSMessageViewController == NO )
                [self showMessageViewController];
        }
    }
}

-(void)postNotification:(NSString*)index {
    NSDictionary *data = [NSDictionary dictionaryWithObject:index forKey:TAB_NUMBER];
    [[NSNotificationCenter defaultCenter] postNotificationName:SetScheduleTabViewNotification object:self userInfo:data];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SetScheduleTabNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ScheduleSendSMSMessage object:nil];
}

#pragma mark - MFMessageCompose Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( isShowSMSMessageViewController == YES ) {
        isShowSMSMessageViewController = NO;
	    [[NSNotificationCenter defaultCenter] postNotificationName:ScheduleSendSMSMessage object:self];
    }
}

- (void) notifier {
    [notifierTimer invalidate];
    notifierTimer = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:ScheduleSendSMSMessage object:self];
}
- (void) showMessageViewController {
    if ( notificationInfo == nil || [notificationInfo count] <= 0 )
        return;
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    isShowSMSMessageViewController = YES;
    NSDictionary *userInfo = notificationInfo[0];
    
    NSString *phoneNumbers = [userInfo valueForKey:@"phoneNumbers"];
    NSArray *phones = [phoneNumbers componentsSeparatedByString:@","];
    NSMutableArray *recepients = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [phones count]; i++ ) {
        [recepients addObject:[phones[i] componentsSeparatedByString:@":"][1]];
    }
    NSString *message = [userInfo valueForKey:@"message"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recepients];
    [messageController setBody:message];
    [messageController.navigationBar setTintColor:[UIColor whiteColor]];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    NSDictionary *userInfo = notificationInfo[0];
    [notificationInfo removeObjectAtIndex:0];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.notificationInfo = notificationInfo;
    switch (result) {
        case MessageComposeResultCancelled:
            NSLog(@"SMS Cancelled");
            isShowSMSMessageViewController = NO;
            notifierTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(notifier) userInfo:nil repeats:NO];
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
        {
            NSLog(@"SMS Sent");
            NSString *scheduleID = [userInfo valueForKey:@"scheduleID"];
            if ( [scheduleListViewControllers count] == 3 ) {
                Schedule *schedule = [(ScheduleTableViewController*)(scheduleListViewControllers[1]) removeSchedule:scheduleID];
                if ( schedule != nil ) {
                    [schedule setState:YES];
                    NSDate *now = [NSDate new];
                    [schedule setReservationDateTime:now];
                    [(ScheduleTableViewController*)(scheduleListViewControllers[2]) addSchedule:schedule isUpdate:NO];
                    [(ScheduleTableViewController*)(scheduleListViewControllers[2]) updateSchedule:schedule isUpdate:YES];
                    
//                    NSDate *curDateTime = [NSDate new];
//                    // Schedule the notification
//                    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
//                    localNotification.fireDate = [[NSDate alloc] initWithTimeIntervalSince1970:[curDateTime timeIntervalSince1970] + 1];
//                    localNotification.alertBody = [NSString stringWithFormat:@"SMS has been sent to %@", [schedule getRecepientNames]];
//                    localNotification.alertAction = @"Show me the item";
//                    localNotification.timeZone = [NSTimeZone defaultTimeZone];
//                    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
//                    
//                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sent SMS" message:[NSString stringWithFormat:@"SMS has been sent to %@", [schedule getRecepientNames]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];

                }
            }
            [self refresh];

            break;
        }
        default:
            NSLog(@"Default");
            break;
    }
    
//    isShowSMSMessageViewController = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - functions
- (void) addSchedule:(Schedule*) schedule isUpdate:(BOOL) isUpdate {
    if ( [scheduleListViewControllers count] == 3 ) {
        if ( [schedule isSent] == YES ) {
            [(ScheduleTableViewController*)(scheduleListViewControllers[2]) addSchedule:schedule isUpdate:isUpdate];
        }
        else {
            [(ScheduleTableViewController*)(scheduleListViewControllers[1]) addSchedule:schedule isUpdate:isUpdate];
        }
    }
}

- (void) updateSchedule:(Schedule*)schedule isUpdate:(BOOL) isUpdate {
    if ( [scheduleListViewControllers count] == 3 ) {
        if ( [schedule isSent] == YES ) {
            [(ScheduleTableViewController*)(scheduleListViewControllers[2]) updateSchedule:schedule isUpdate:isUpdate];
        }
        else {
            [(ScheduleTableViewController*)(scheduleListViewControllers[1]) updateSchedule:schedule isUpdate:isUpdate];
        }
    }
}

- (void) removeSchedule:(Schedule*)schedule isUpdate:(BOOL)isUpdate {
    if ( [scheduleListViewControllers count] == 3 ) {
        if ( [schedule isSent] == YES ) {
            [(ScheduleTableViewController*)(scheduleListViewControllers[2]) removeSchedule:schedule isUpdate:isUpdate];
        }
        else {
            [(ScheduleTableViewController*)(scheduleListViewControllers[1]) removeSchedule:schedule isUpdate:isUpdate];
        }
    }
}
- (void) changeSchedule:(Schedule*)schedule {
    if ( [scheduleListViewControllers count] == 3 ) {
        [(ScheduleTableViewController*)(scheduleListViewControllers[2]) removeSchedule:schedule isUpdate:NO];
        [(ScheduleTableViewController*)(scheduleListViewControllers[1]) addSchedule:schedule isUpdate:NO];
        [(ScheduleTableViewController*)(scheduleListViewControllers[1]) updateSchedule:schedule isUpdate:YES];
    }
}

- (void) refresh {
    ScheduleTableViewController *allViewController = scheduleListViewControllers[0];
    ScheduleTableViewController *scheduledViewController = scheduleListViewControllers[1];
    ScheduleTableViewController *sentViewController = scheduleListViewControllers[2];
    
    [scheduledViewController refresh];
    [sentViewController refresh];
    
    [[allViewController scheduleList] removeAllObjects];
    [[allViewController scheduleList] addObject:[scheduledViewController scheduleList]];
    [[allViewController scheduleList] addObject:[sentViewController scheduleList]];
    
    [allViewController refresh];
}

#pragma mark - Select Tab

- (void)jumpToTab:(NSInteger)tab {
    if ( currentPage != tab ) {
        NSInteger direction = UIPageViewControllerNavigationDirectionForward;
        int incValue = 1;
        if ( currentPage > tab ) {
            direction = UIPageViewControllerNavigationDirectionReverse;
            incValue = -1;
        }
//        while ( tab != currentPage && tab >= 0 && tab <= 2) {
        int num = abs((int)currentPage - (int)tab);
        if ( num == 2 ) {
            UIViewController *controller = [self viewControllerAtIndex:currentPage + incValue];
            [self.pageController setViewControllers:@[controller]
                                          direction:direction
                                           animated:NO
                                         completion:nil];
        }
        UIViewController *controller = [self viewControllerAtIndex:currentPage + incValue];
        [self.pageController setViewControllers:@[controller]
                                 direction:direction
                                  animated:YES
                                completion:nil];
    }
}

- (ScheduleTableViewController *)viewControllerAtIndex:(NSUInteger)index {
    ScheduleTableViewController *childViewController;
    if ( index < [scheduleListViewControllers count] ) {
        childViewController = [scheduleListViewControllers objectAtIndex:index];
    }
    else {
        childViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScheduleTableViewController"];
        childViewController.index = index;
    }
    
    currentPage = index;
    
    return childViewController;
    
}


#pragma mark - UIPageViewDelegate

- (ScheduleTableViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [(ScheduleTableViewController *)viewController index];
    
//    [self postNotification:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
    [((ViewController*)self.parentViewController).tabView setTab:index + 100];
    
    if (index == 0 || index == NSNotFound) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (ScheduleTableViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [(ScheduleTableViewController *)viewController index];
    
//    [self postNotification:[NSString stringWithFormat:@"%lu", (unsigned long)index]];
    [((ViewController*)self.parentViewController).tabView setTab:index + 100];
    index++;
    
    if (index == 3 || index == NSNotFound) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

@end
