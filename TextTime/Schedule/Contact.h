//
//  Contact.h
//  TextTime
//
//  Created by admin on 6/10/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject {
    NSString *cid;
    NSString *cname;
    NSMutableDictionary *cphoneList;
    NSMutableDictionary *cemailList;
    NSString *cimageUri;
    UIImage *cimage;
}

-(void)setContactId:(NSString*)contactId;
-(void)setContactName:(NSString*)contactName;
-(void)addPhoneNumber:(NSString*)type phoneNumber:(NSString*)phoneNumber;
-(void)addPhoneNumbers:(NSString*)phoneNumbers;
-(NSString*)getContactId;
-(NSString*)getContactName;
-(NSDictionary*)getPhoneList;
-(NSString*)getPhoneNumbers;
-(BOOL)isEqual:(id)object;

- (NSString*) toString;
- (BOOL) setContactFromString:(NSString*)contactString;

@end
