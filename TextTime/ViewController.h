//
//  ViewController.h
//  TextTime
//
//  Created by admin on 6/9/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TabView;
@class ScheduleViewController;

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet TabView *tabView;
@property (weak, nonatomic) IBOutlet UIView *scheduleContainerView;
@property (strong, nonatomic) ScheduleViewController *scheduleViewController;

@end
