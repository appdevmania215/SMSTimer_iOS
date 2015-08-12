//
//  ScheduledDBManager.m
//  TextTimer
//
//  Created by admin on 6/21/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "ScheduledDBManager.h"

@implementation ScheduledDBManager

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        [self setState:NO];
    }
    return self;
}

@end
