//
//  TabView.h
//  TextTime
//
//  Created by admin on 6/9/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface TabView : UIView

@property (weak, nonatomic) IBOutlet UILabel *shadowLabel;

@property(nonatomic, setter = setParentViewController:) ViewController *parentViewController;
- (void) setNotificationManager;
- (void) receiveNotification:(NSNotification *)notification;
-(void)postNotification:(NSString*)index;
-(void) setTab;
-(void) setTab:(long) tab;

@end
