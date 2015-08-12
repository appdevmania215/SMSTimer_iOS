//
//  AppDelegate.m
//  TextTime
//
//  Created by admin on 6/9/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"
#import <AddressBook/AddressBook.h>
@implementation AppDelegate

@synthesize notificationInfo;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        [[UINavigationBar appearance] setTintColor: [UIColor colorWithRed:56/255.0 green:114/255.0 blue:136/255.0 alpha:1.0]];
    }
    else
    {
        [[UINavigationBar appearance] setBarTintColor: [UIColor colorWithRed:56/255.0 green:114/255.0 blue:136/255.0 alpha:1.0]];
    }
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // None of the code should even be compiled unless the Base SDK is iOS 8.0 or later
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    // The following line must only run under iOS 8. This runtime check prevents
    // it from running if it doesn't exist (such as running under iOS 7 or earlier).
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        application.applicationIconBadgeNumber=0;
    }
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }
 #endif
    CFErrorRef cferror = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &cferror);
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted == false)
            {
                
                return ;
            }
        });
    });
    

    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    exit(0);

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    application.applicationIconBadgeNumber = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:ScheduleSendSMSMessage object:self];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if ( state == UIApplicationStateActive ) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
       application.applicationIconBadgeNumber = 0;
    }
    NSDictionary *userInfo = notification.userInfo;
   application.applicationIconBadgeNumber = 0;

    if ( userInfo != nil ) {
    	[self addNotification:userInfo];
    }
}

- (void) addNotification:(NSDictionary*)info {
    if ( info == nil )
        return;
    if ( notificationInfo == nil )
        notificationInfo = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [notificationInfo count]; i++ ) {
        NSDictionary *temp = notificationInfo[i];
        if ( [[temp valueForKey:@"scheduleID"] isEqualToString:[info valueForKey:@"scheduleID"]] )
            return;
    }
    [notificationInfo addObject:info];
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if ( state == UIApplicationStateActive && notificationInfo != nil && [notificationInfo count] == 1 ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ScheduleSendSMSMessage object:self];
    }
}

@end
