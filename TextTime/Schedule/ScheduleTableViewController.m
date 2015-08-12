//
//  ScheduleTableViewController.m
//  TextTime
//
//  Created by admin on 6/10/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "ScheduleTableViewController.h"
#import "../Compose/ComposeViewController.h"
#import "Constants.h"
#import "Schedule.h"
#import "Contact.h"
#import "ScheduleTableViewCell.h"
#import "ViewController.h"
#import "ScheduleViewController.h"

#import "TextTimerDBManager.h"
#import "ScheduledDBManager.h"
#import "SentDBManager.h"
#import "../AppDelegate.h"

@interface ScheduleTableViewController ()

@property (nonatomic, strong)  NSMutableArray *scheduleList;

@end

@implementation ScheduleTableViewController

@synthesize scheduleList = _scheduleList;
@synthesize mParentViewController;

//+ (ScheduleTableViewController *)shareInstance {
//    static ScheduleTableViewController *__singletion;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        __singletion=[[self alloc] init];
//    });
//    return __singletion;
//}

-(void)setType:(NSInteger)type {
    scheduleType = type;
}

- (NSMutableArray *)scheduleList {
    if ( !_scheduleList ) {
        if ( scheduleType != ALL ) {
            if ( scheduleType == SCHEDULED ) {
                dbManager = [[ScheduledDBManager alloc] init];
            }
            else {
                dbManager = [[SentDBManager alloc] init];
            }
            _scheduleList = [dbManager selectAll];
        }
        else {
            _scheduleList = [[NSMutableArray alloc] init];
        }
    }

    return _scheduleList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ( !scheduleType )
        scheduleType = SCHEDULED;
    self.refreshControl = nil;
}
- (void)viewWillAppear:(BOOL)animated {
    [self setup];
}

- (void) viewWillDisappear:(BOOL)animated {
    [timer invalidate];
    timer = nil;
}

- (void) setup {
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimer:) userInfo:nil repeats:YES];
    [self.tableView reloadData];
}
- (void) startTimer:(id)sender {
    NSDate *curdatetime = [NSDate new];
    long timeinterval = [curdatetime timeIntervalSince1970];
    if ( timeinterval % 60 == 0 ) {
        [timer invalidate];
        timer = nil;
        [self.tableView reloadData];
        timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(setTimer:) userInfo:nil repeats:YES];
    }
}
- (void) setTimer:(id)sender {
    [self.tableView reloadData];
}
- (void) refresh {
    if ( scheduleType != ALL ) {
    	NSSortDescriptor *valueDescriptor;
        if ( scheduleType == SENT )
            valueDescriptor  = [[NSSortDescriptor alloc] initWithKey:@"sreservationDateTime" ascending:NO];
        else
            valueDescriptor  = [[NSSortDescriptor alloc] initWithKey:@"sreservationDateTime" ascending:YES];
        
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSMutableArray *temp = [(NSArray*)[[self scheduleList] sortedArrayUsingDescriptors:descriptors] mutableCopy];
        [[self scheduleList] removeAllObjects];
        self.scheduleList = temp;
    }
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if ( scheduleType != ALL )
        return [[self scheduleList] count];
    NSInteger count = 0;
    NSArray *list = [self scheduleList];
    for ( int i = 0; i < [list count]; i++ ) {
        count += [list[i] count];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    long row = [indexPath row];

    Schedule *schedule;
    NSArray *list = [self scheduleList];
    if ( scheduleType == ALL ) {
        for ( int i = 0; i < [list count]; i++ ) {
            NSInteger count = [list[i] count];
            if ( row < count ) {
                schedule = (Schedule*)list[i][row];
                break;
            }
            row -= count;
        }
    }
    else {
        schedule = (Schedule*)[self scheduleList][row];
    }
    NSString *cellIdentifier;
    if ( [schedule isSent] == YES )
        cellIdentifier = @"Sent";
    else
        cellIdentifier = @"Scheduled";
    ScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.lblRecepientName.text = [schedule getRecepientNames];
    cell.lblMessage.text = [schedule getMessage];
    cell.lblReservationDateTime.text = [schedule getScheduleDateTimeString];
    
    if ( [schedule isSent] == NO ) {
        cell.lblRemainingDateTime.text = [schedule getRemainingDateTime];
        if ( schedule.isPassed == YES ) {
            cell.backgroundColor = [UIColor colorWithWhite:0.95f alpha:0.5f];
        }
        else {
            cell.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    long row = [indexPath row];
    Schedule *schedule;
    NSArray *list = [self scheduleList];
    if ( scheduleType == ALL ) {
        for ( int i = 0; i < [list count]; i++ ) {
            NSInteger count = [list[i] count];
            if ( row < count ) {
                schedule = (Schedule*)list[i][row];
                break;
            }
            row -= count;
        }
    }
    else {
        schedule = (Schedule*)[self scheduleList][row];
    }
    if ( [schedule isSent] == YES )
        return 59.0f;
    else
        return 79.0f;
}


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    long row = [indexPath row];
    Schedule *schedule;
    NSArray *list = [self scheduleList];
    if ( scheduleType == ALL ) {
        for ( int i = 0; i < [list count]; i++ ) {
            NSInteger count = [list[i] count];
            if ( row < count ) {
                schedule = (Schedule*)list[i][row];
                break;
            }
            row -= count;
        }
    }
    else {
        schedule = (Schedule*)[self scheduleList][row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ComposeViewController *composeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ComposeViewController"];
    [composeViewController setEditable:NO];
    [composeViewController setState:schedule];
    [composeViewController setScheduleViewController:mParentViewController];
    [mParentViewController.navigationController pushViewController:composeViewController animated:YES];
}


#pragma mark - Functions

- (void) addSchedule:(Schedule*) schedule isUpdate:(BOOL) isUpdate {
    NSMutableArray *scheduleList = [self scheduleList];
    if ( scheduleList != nil ) {
        if ( isUpdate == YES ) {
            NSString *scheduleID = [dbManager insertData:schedule];
            [schedule setScheduleId:scheduleID];
        }
        [scheduleList addObject:schedule];
    }
}

- (void) updateSchedule:(Schedule*) schedule isUpdate:(BOOL) isUpdate {
    NSMutableArray *scheduleList = [self scheduleList];
    if ( scheduleList != nil ) {
        if ( isUpdate == YES ) {
            [dbManager updateData:schedule];
        }
    }
}

- (void) removeSchedule:(Schedule *)schedule isUpdate:(BOOL) isUpdate {
    NSMutableArray *scheduleList = [self scheduleList];
    if ( scheduleList != nil ) {
        [scheduleList removeObject:schedule];
    }
    if ( isUpdate == YES ) {
        [dbManager removeData:[schedule getScheduleId]];
    }
}

- (Schedule*) removeSchedule:(NSString*)scheduleID {
    NSMutableArray *scheduleList = [self scheduleList];
    Schedule *schedule = nil;
    if ( scheduleList != nil ) {
        for ( int i = 0; i < [scheduleList count]; i++ ) {
            Schedule* temp = scheduleList[i];
            if ( [scheduleID isEqualToString:[temp getScheduleId]] ) {
                schedule = temp;
                [scheduleList removeObjectAtIndex:i];
                break;
            }
        }
    }
    return schedule;
}
@end
