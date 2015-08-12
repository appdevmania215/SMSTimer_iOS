//
//  AppDelegate.h
//  TextTime
//
//  Created by admin on 6/9/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSMutableArray *notificationInfo;
}

@property (strong, nonatomic) NSMutableArray *notificationInfo;
@property (strong, nonatomic) UIWindow *window;

- (void) addNotification:(NSDictionary*)info;

@end
