//
//  RecepientsContainerView.h
//  TextTimer
//
//  Created by admin on 6/19/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Contact;
@class RecepientTagView;
@class ComposeViewController;

@interface RecepientsContainerView : UIView {
    CGFloat nextX;
    CGFloat nextY;
    CGFloat nextHeight;
    CGFloat maxWidth;
}

@property(nonatomic, setter = setParentViewController:) ComposeViewController *mParentViewController;
@property(strong, nonatomic) NSMutableArray *recepientsArray;
@property(nonatomic, setter = setEditable:) BOOL isEditable;

- (CGFloat) addRecepient:(Contact*)contact;
- (void) deleteRecepient:(RecepientTagView*)tagView;
- (CGFloat) getSize;

-(void) reloadRecepients;

@end
