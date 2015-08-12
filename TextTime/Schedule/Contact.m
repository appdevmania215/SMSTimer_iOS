//
//  Contact.m
//  TextTime
//
//  Created by admin on 6/10/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "Contact.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"

@implementation Contact

-(void)setContactId:(NSString*)contactId {
    cid = contactId;
}
-(void)setContactName:(NSString*)contactName {
    cname = contactName;
}
-(void)addPhoneNumber:(NSString*)type phoneNumber:(NSString*)phoneNumber {
    if ( cphoneList == nil ) {
        cphoneList = [[NSMutableDictionary alloc] init];
    }
    [cphoneList setObject:phoneNumber forKey:type];
}
-(void)addPhoneNumbers:(NSString*)phoneNumbers {
    NSArray *arr = [phoneNumbers componentsSeparatedByString:@","];
    if ( arr == nil || [arr count] == 0 )
        return;
    
    for ( int i = 0; i < [arr count]; i++ ) {
        NSArray *pNum = [arr[i] componentsSeparatedByString:@":"];
        if ( [pNum count] == 2 )
            [self addPhoneNumber:pNum[0] phoneNumber:pNum[1]];
    }
}
-(void)addPhoneNumbersFromString:(NSString*)phoneNumbers {
    NSData *theJSONData = [phoneNumbers dataUsingEncoding:NSUTF8StringEncoding];
    CJSONDeserializer *theDeserializer = [CJSONDeserializer deserializer];
    theDeserializer.options |= kJSONDeserializationOptions_AllowFragments;
    NSError *theError = NULL;
    NSDictionary *dic = [theDeserializer deserializeAsDictionary:theJSONData error:&theError];
    if ( theError == nil ) {
        NSArray *keys = [dic allKeys];
        for ( int i = 0; i < [keys count]; i++ ) {
            NSString *key = keys[i];
            NSString *value = [dic valueForKey:key];
            [self addPhoneNumber:key phoneNumber:value];
        }
    }
}
-(NSString*)getContactId {
    return cid;
}
-(NSString*)getContactName {
    return cname;
}
-(NSDictionary*)getPhoneList {
    return cphoneList;
}
-(NSString*)getPhoneNumbers {
    NSArray *keys = [cphoneList allKeys];
    NSString *phoneNumbers;
    
    for ( int i = 0; i < [keys count]; i++ ) {
        NSString *key = keys[i];
        NSString *value = [cphoneList valueForKey:key];
        if ( [phoneNumbers length] != 0 ) {
            phoneNumbers = [NSString stringWithFormat:@"%@,", phoneNumbers];
        }
        phoneNumbers = [NSString stringWithFormat:@"%@%@:%@", phoneNumbers, key, value];
    }
    
    return phoneNumbers;
}
-(BOOL)isEqual:(id)object {
    if ( [[self getContactId] isEqualToString:[((Contact*)object) getContactId]] )
        return YES;
    return NO;
}

-(NSString*)getPhoneNumbersToString {
    CJSONSerializer *theSerializer = [CJSONSerializer serializer];
    theSerializer.options = kJSONSerializationOptions_EncodeSlashes;
    id theObject = [theSerializer serializeObject:cphoneList error:nil];
    NSString *resultString = [[NSString alloc] initWithData:theObject encoding:NSUTF8StringEncoding];
    return resultString;
}
-(NSString*)toString {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:[self getContactId] forKey:@"cid"];
    [dic setObject:[self getContactName] forKey:@"cname"];
    [dic setObject:[self getPhoneNumbersToString] forKey:@"cphonenumbers"];
    
    CJSONSerializer *theSerializer = [CJSONSerializer serializer];
    theSerializer.options = kJSONSerializationOptions_EncodeSlashes;
    id theObject = [theSerializer serializeObject:dic error:nil];
    NSString *resultString = [[NSString alloc] initWithData:theObject encoding:NSUTF8StringEncoding];
    return resultString;
}

- (BOOL) setContactFromString:(NSString*)contactString {
    NSData *theJSONData = [contactString dataUsingEncoding:NSUTF8StringEncoding];
    CJSONDeserializer *theDeserializer = [CJSONDeserializer deserializer];
    theDeserializer.options |= kJSONDeserializationOptions_AllowFragments;
    NSError *theError = NULL;
    NSDictionary *dic = [theDeserializer deserializeAsDictionary:theJSONData error:&theError];
    if ( theError == nil ) {
        [self setContactId:[dic valueForKey:@"cid"]];
        [self setContactName:[dic valueForKey:@"cname"]];
        [self addPhoneNumbersFromString:[dic valueForKey:@"cphonenumbers"]];
        return YES;
    }
    else
        return NO;
}

@end
