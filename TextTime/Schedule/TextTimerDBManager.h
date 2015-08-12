//
//  TextTimerDBManager.h
//  TextTimer
//
//  Created by admin on 6/21/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Schedule;
@class SQLiteManager;

@interface TextTimerDBManager : NSObject {
//    SQLiteManager *dbManager;
}

@property (nonatomic, setter = setState:) BOOL isSent;
@property (nonatomic, setter = setDBManager:)SQLiteManager *dbManager;

- (NSString*) escapeString:(NSString*)string;

- (void) createTable;
- (void) removeTable;
- (NSString*) insertData:(Schedule*)schedule;
- (void) updateData:(Schedule*)schedule;
- (void) updateSchedule:(NSString*)scheduleID;
- (void) removeData:(NSString*)index;
- (Schedule*) selectData:(NSInteger)index;
- (NSMutableArray*) selectAll;

@end
