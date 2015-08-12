//
//  ScheduleViewController.h
//  TextTime
//
//  Created by admin on 6/10/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class CustomButton;
@class SQLiteManager;
@class Schedule;

@interface ScheduleViewController : UIViewController<UIPageViewControllerDataSource, UIPageViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate> {
    NSInteger currentPage;
    SQLiteManager *dbManager;
    NSMutableArray *notificationInfo;
    NSTimer *notifierTimer;
}

@property (strong, nonatomic) UIPageViewController *pageController;
@property (weak, nonatomic) IBOutlet UIView *ContainerView;
@property (weak, nonatomic) IBOutlet CustomButton *btnCompose;

- (void) postNotification:(NSString*)index;
- (void) setNotificationManager;
- (void) receiveNotification:(NSNotification *)notification;
- (void) jumpToTab:(NSInteger)tab;

- (void) addSchedule:(Schedule*)schedule isUpdate:(BOOL) isUpdate;
- (void) updateSchedule:(Schedule*)schedule isUpdate:(BOOL) isUpdate;
- (void) removeSchedule:(Schedule*)schedule isUpdate:(BOOL)isUpdate;
- (void) changeSchedule:(Schedule*)schedule;

- (void) refresh;

@end
