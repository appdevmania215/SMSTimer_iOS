//
//  TextTimerDBManager.m
//  TextTimer
//
//  Created by admin on 6/21/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "TextTimerDBManager.h"
#import "Schedule.h"
#import "Contact.h"
#import "SQLiteManager.h"
#import "../Constants.h"

#define TABLE_NAME @"schedule"

@implementation TextTimerDBManager

@synthesize isSent;
@synthesize dbManager;

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        if ( dbManager == nil )
	        dbManager = [[SQLiteManager alloc] initWithDatabaseNamed:@"texttimer.db"];
//        [self removeTable];
        [self createTable];
    }
    return self;
}

- (NSString*) escapeString:(NSString*)string {
    if ( string == nil || [string isEqualToString:@""] )
        return @"";
    NSString *result = [string stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
    result = [result stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    return result;
}
- (void) createTable {
    NSString *sqlStr = [NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement, contacts text not null, reservationDateTime text not null, message text not null, state text not null);", TABLE_NAME];
    NSError *error = [dbManager doQuery:sqlStr];
	if (error != nil) {
		NSLog(@"Error: %@",[error localizedDescription]);
	}
}
- (void) removeTable {
    NSString *sqlStr = [NSString stringWithFormat:@"drop table %@;", TABLE_NAME];
    NSError *error = [dbManager doQuery:sqlStr];
	if (error != nil) {
		NSLog(@"Error: %@",[error localizedDescription]);
	}
}
- (NSString*) insertData:(Schedule*)schedule {
    NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(contacts, reservationDateTime, message, state) values('%@', '%@', '%@', '%@');",
                        TABLE_NAME,
                        [schedule getRecepientsToString],
                        [schedule getReservationDateTimeString],
                        [self escapeString:[schedule getMessage]],
                        ScheduleStandBy];
    NSError *error = [dbManager doQuery:sqlStr];
	if (error != nil) {
		NSLog(@"Error: %@",[error localizedDescription]);
        return @"";
	}
	else {
	    return [NSString stringWithFormat:@"%ld", (long)[dbManager getLastScheduleId]];
    }
}

- (void) updateData:(Schedule*)schedule {
    NSString *scheduleState = @"";
    if ( [schedule isSent] == YES ) {
        scheduleState = ScheduleSent;
    }
    else {
        scheduleState = ScheduleStandBy;
    }
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set  contacts='%@', reservationDateTime='%@', message='%@', state='%@' where id=%@;",
                        TABLE_NAME,
                        [schedule getRecepientsToString],
                        [schedule getReservationDateTimeString],
                        [self escapeString:[schedule getMessage]],
                        scheduleState,
                        [schedule getScheduleId]];
    NSError *error = [dbManager doQuery:sqlStr];
	if (error != nil) {
		NSLog(@"Error: %@",[error localizedDescription]);
	}
}
- (void) updateSchedule:(NSString*)scheduleID {
    NSString *sqlStr = [NSString stringWithFormat:@"update %@ set  state='%@' where id=%@;",
                        TABLE_NAME,
                        ScheduleSent,
                        scheduleID];
    NSError *error = [dbManager doQuery:sqlStr];
	if (error != nil) {
		NSLog(@"Error: %@",[error localizedDescription]);
	}
}

- (void) removeData:(NSString*)index {
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where id=%@;", TABLE_NAME, index];
    NSError *error = [dbManager doQuery:sqlStr];
	if (error != nil) {
		NSLog(@"Error: %@",[error localizedDescription]);
	}
}
- (Schedule*) selectData:(NSInteger)index {
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where id=%ld;", TABLE_NAME, (long)index];
    NSArray *result = [dbManager getRowsForQuery:sqlStr];
    if ( result != nil && [result count] > 0 ) {
        Schedule *schedule = [[Schedule alloc] init];
        NSDictionary *row = result[0];
        [schedule setScheduleId:[NSString stringWithFormat:@"%@", [row valueForKey:@"id"]]];
        [schedule setReservationDateTimeFromString:[row valueForKey:@"reservationDateTime"]];
        [schedule setMessage:[row valueForKey:@"message"]];
        [schedule setRecepientsFromString:[row valueForKey:@"contacts"]];
        [schedule setState:isSent];
        
        return schedule;
    }
    return nil;
}
- (NSMutableArray*) selectAll {
    NSMutableArray *scheduleList = [[NSMutableArray alloc] init];
    
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@", TABLE_NAME];
//    if ( isSent == YES ) {
//        sqlStr = [NSString stringWithFormat:@"%@ where reservationDateTime <= datetime('now', 'localtime') order by reservationDateTime DESC, contactName ASC;", sqlStr];
//    }
//    else {
//        sqlStr = [NSString stringWithFormat:@"%@ where reservationDateTime > datetime('now', 'localtime') order by reservationDateTime ASC, contactName ASC;", sqlStr];
//    }
    if ( isSent == YES ) {
        sqlStr = [NSString stringWithFormat:@"%@ where state='%@' order by reservationDateTime DESC;", sqlStr, ScheduleSent];
    }
    else {
        sqlStr = [NSString stringWithFormat:@"%@ where state='%@' order by reservationDateTime ASC;", sqlStr, ScheduleStandBy];
    }

    NSArray *result = [dbManager getRowsForQuery:sqlStr];
    if ( result != nil && [result count] > 0 ) {
        for ( int i = 0; i < [result count]; i++ ) {
            Schedule *schedule = [[Schedule alloc] init];
            NSDictionary *row = result[i];
            [schedule setScheduleId:[row valueForKey:@"id"]];
            [schedule setReservationDateTimeFromString:[row valueForKey:@"reservationDateTime"]];
            [schedule setMessage:[row valueForKey:@"message"]];
            NSString *scheduleState = [row valueForKey:@"state"];
            if ( [scheduleState isEqualToString:ScheduleStandBy] )
                [schedule setState:NO];
            else
                [schedule setState:YES];
            [schedule setRecepientsFromString:[row valueForKey:@"contacts"]];
            [scheduleList addObject:schedule];
        }
    }
    return scheduleList;
}

- (void)dealloc {
    [dbManager closeDatabase];
    dbManager = nil;
}
@end
