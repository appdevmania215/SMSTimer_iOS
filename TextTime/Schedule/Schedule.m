//
//  Schedule.m
//  TextTime
//
//  Created by admin on 6/10/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "Schedule.h"
#import "Contact.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "../AppDelegate.h"
#import "../Constants.h"

@implementation Schedule

- (id)init {
    self = [super init];
    if (self) {
        // Initialization code
        [self setState:NO];
    }
    return self;
}

-(void)setScheduleId:(NSString*)scheduleid {
    sid = scheduleid;
}
-(void)addRecepient:(Contact *)contact {
    if ( contactsList == nil )
        contactsList = [[NSMutableArray alloc] init];
    [contactsList addObject:contact];
}
-(void)setRecepients:(NSMutableArray*)contacts {
    if ( contactsList != nil )
	    [contactsList removeAllObjects];
    contactsList = contacts;
}
-(void)setRecepientsFromString:(NSString *)contactsString {
    NSData *theJSONData = [contactsString dataUsingEncoding:NSUTF8StringEncoding];
    CJSONDeserializer *theDeserializer = [CJSONDeserializer deserializer];
    theDeserializer.options |= kJSONDeserializationOptions_AllowFragments;
    NSError *theError = NULL;
    NSArray *contacts = [theDeserializer deserializeAsArray:theJSONData error:&theError];
    if ( contacts != nil ) {
        for ( int i = 0; i < [contacts count]; i++ ) {
            Contact *contact = [[Contact alloc] init];
            if ( [contact setContactFromString:contacts[i]] == YES )
                [self addRecepient:contact];
        }
    }
}
-(void)setMessage:(NSString*)message {
    smessage = message;
}
-(void)setReservationDateTime:(NSDate*)datetime {
    sreservationDateTime = datetime;
}
-(void)setReservationDateTimeFromString:(NSString *)datetime {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    sreservationDateTime = [df dateFromString:datetime];
}
-(void)setState:(BOOL)issent {
    sisSent = issent;
}
-(NSString*)getScheduleId {
    return [NSString stringWithFormat:@"%@", sid];
}
-(NSArray*)getRecepients {
    return contactsList;
}
-(NSString*)getRecepientNames {
    NSMutableArray *contactNames = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [contactsList count]; i++ ) {
        Contact* contact = contactsList[i];
        [contactNames addObject:[contact getContactName]];
    }
    return [contactNames componentsJoinedByString:@", "];
}
-(NSString*)getRecepientsToString {
    NSMutableArray *contacts = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [contactsList count]; i++ ) {
        Contact *contact = contactsList[i];
        [contacts addObject:[contact toString]];
    }
    NSData *output = [[CJSONSerializer serializer] serializeObject:contacts error:nil];
    return [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
}
-(NSString*)getPhoneNumbers {
    NSString *phoneNumbers = @"";
    if ( contactsList != nil ) {
    	for ( int i = 0; i < [contactsList count]; i++ ) {
            Contact *contact = contactsList[i];
            if ( i != 0 )
                phoneNumbers = [NSString stringWithFormat:@"%@,", phoneNumbers];
            phoneNumbers = [NSString stringWithFormat:@"%@%@", phoneNumbers, [contact getPhoneNumbers]];
        }
    }
    return phoneNumbers;
}
-(NSString*)getMessage {
    return smessage;
}

-(NSDate*)getReservationDateTime {
    return sreservationDateTime;
}

-(NSString*)getReservationDateTimeString {
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    return [df stringFromDate:sreservationDateTime];
}
-(NSString*)getScheduleDateTimeString {
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"MMM dd hh:mm aa"];
    return [df stringFromDate:sreservationDateTime];
}
- (BOOL) isPassed {
    NSDate *now = [NSDate new];
    long reservationTimeStamp = [sreservationDateTime timeIntervalSince1970];
    long curTimeStamp = [now timeIntervalSince1970];
    long minutes = round(reservationTimeStamp / 60) - round(curTimeStamp / 60);
    if ( minutes <= 0 ) {
        return YES;
    }
    return NO;
}
-(NSString*)getRemainingDateTime {
    NSDate *now = [NSDate new];
    long reservationTimeStamp = [sreservationDateTime timeIntervalSince1970];
    long curTimeStamp = [now timeIntervalSince1970];
    NSString *label = @"";
    NSString *remainingTime = @"";
    long minutes = round(reservationTimeStamp / 60) - round(curTimeStamp / 60);
    if ( minutes < 0 ) {
//        [self setPassedState:YES];
        label = @"hours passed";
        minutes = 0 - minutes;
    }
    else {
//        [self setPassedState:NO];
        label = @"hours until sent";
    }
    
    long hours = round(minutes / 60);
    long days = round(hours / 24);
    hours = hours % 24;
    minutes = minutes % 60;
    if ( days > 0 )
        remainingTime = [NSString stringWithFormat:@"%@%ld", remainingTime, days];
    if ( days == 1 )
        remainingTime = [NSString stringWithFormat:@"%@day ", remainingTime];
    else if ( days > 1 )
        remainingTime = [NSString stringWithFormat:@"%@days ", remainingTime];
    remainingTime = [NSString stringWithFormat:@"%@%ld:", remainingTime, hours];
    if ( minutes < 10 )
        remainingTime = [NSString stringWithFormat:@"%@0", remainingTime];
    remainingTime = [NSString stringWithFormat:@"%@%ld %@", remainingTime, minutes, label];
    return remainingTime;
}
-(BOOL)isSent {
    return sisSent;
}

-(void)dealloc {
    [contactsList removeAllObjects];
    contactsList = nil;
}

@end
