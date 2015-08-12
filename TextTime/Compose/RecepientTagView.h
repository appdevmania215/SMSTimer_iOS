//
//  RecepientTagView.h
//  TextTimer
//
//  Created by admin on 6/19/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact.h"

@class RecepientsContainerView;

@interface RecepientTagView : UIView<UIAlertViewDelegate>

@property (assign, nonatomic) CGSize mSize;
@property (strong, nonatomic) Contact* mContact;

@property (nonatomic, setter = setIndex:) NSInteger mIndex;
@property (nonatomic, setter = setParent:) RecepientsContainerView *mParentView;

- (CGSize) getSize;
- (CGSize) setContact:(Contact*)contact;

@end
