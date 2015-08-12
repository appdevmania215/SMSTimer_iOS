//
//  ScheduleTableViewController.h
//  TextTime
//
//  Created by admin on 6/10/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Schedule;
@class TextTimerDBManager;
@class ScheduleViewController;

@interface ScheduleTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate> {
    NSInteger scheduleType;
    TextTimerDBManager *dbManager;
    NSTimer *timer;
}

@property (assign, nonatomic) NSInteger index;
@property (nonatomic, setter = setParentScheduleViewController:) ScheduleViewController *mParentViewController;

//+(ScheduleTableViewController*)shareInstance;
- (void)setType:(NSInteger)type;
- (void) refresh;

- (void) addSchedule:(Schedule*)schedule isUpdate:(BOOL) isUpdate;
- (void) updateSchedule:(Schedule*)schedule isUpdate:(BOOL) isUpdate;
- (void) removeSchedule:(Schedule*)schedule isUpdate:(BOOL)isUpdate;
- (Schedule*) removeSchedule:(NSString*)scheduleID;

- (NSMutableArray *)scheduleList;

@end
