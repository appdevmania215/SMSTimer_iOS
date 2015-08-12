//
//  ViewController.m
//  TextTime
//
//  Created by admin on 6/9/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import "TabView.h"
#import "Schedule/ScheduleViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize scheduleViewController;

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [_tabView setTab];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSArray *childViewControllers = self.childViewControllers;
    [self.tabView setParentViewController:self];
    for ( int i = 0; i < [childViewControllers count]; i++ ) {
        if ( [childViewControllers[i] isKindOfClass:[ScheduleViewController class]] ) {
            scheduleViewController = childViewControllers[i];
            break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Notification
//
//- (void) setNotificationManager {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:SetScheduleTabNotification object:nil];
//}
//
//- (void) receiveNotification:(NSNotification *)notification {
//    if ( [[notification name] isEqualToString:SetScheduleTabNotification] ) {
//        
//    }
//}
//
//-(void)postNotification:(NSString*)index {
//    NSDictionary *data = [NSDictionary dictionaryWithObject:index forKey:TAB_NUMBER];
//    [[NSNotificationCenter defaultCenter] postNotificationName:SetScheduleTabViewNotification object:self userInfo:data];
//}
//
//-(void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:SetScheduleTabNotification object:nil];
//}

@end
