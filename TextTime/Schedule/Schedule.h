//
//  Schedule.h
//  TextTime
//
//  Created by admin on 6/10/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Contact;

@interface Schedule : NSObject {
    NSString *sid;
//    Contact *srecepient;
    NSString *smessage;
    NSDate *sreservationDateTime;
    BOOL sisSent;
    
    NSMutableArray *contactsList;
}

//@property (nonatomic, setter = setPassedState:) BOOL isPassed;
- (BOOL) isPassed;
-(void)setScheduleId:(NSString*)scheduleid;
-(void)addRecepient:(Contact*)contact;
-(void)setRecepients:(NSMutableArray*)contacts;
-(void)setRecepientsFromString:(NSString *)contactsString;
-(void)setMessage:(NSString*)message;
-(void)setReservationDateTime:(NSDate*)datetime;
-(void)setReservationDateTimeFromString:(NSString *)datetime;
-(void)setState:(BOOL)issent;

-(NSString*)getScheduleId;
-(NSArray*)getRecepients;
-(NSString*)getRecepientNames;
-(NSString*)getRecepientsToString;
-(NSString*)getPhoneNumbers;
-(NSString*)getMessage;
-(NSDate*)getReservationDateTime;
-(NSString*)getReservationDateTimeString;
-(NSString*)getScheduleDateTimeString;
-(NSString*)getRemainingDateTime;
-(BOOL)isSent;

@end
