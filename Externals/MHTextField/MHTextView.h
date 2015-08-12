//
//  MHTextView.h
//
//  Created by Mehfuz Hossain on 4/11/13.
//  Copyright (c) 2013 Mehfuz Hossain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MHTextView;
UIKIT_EXTERN NSString * const UITextViewTextShouldBeginEditingNotification;
@protocol MHTextViewDelegate <NSObject>

@required

- (MHTextView*) textViewAtIndex:(int)index;
- (int) numberOfTextViews;

@end

@interface MHTextView : UITextView

@property (nonatomic) BOOL required;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIScrollView *superScrollView;
@property (nonatomic, setter = setDateView:) BOOL isDateView;
@property (nonatomic, setter = setEmailView:) BOOL isEmailView;
@property (nonatomic, setter = setValidView:) BOOL isValidView;
@property (nonatomic, setter = setTopHeight:) CGFloat topHeight;

@property (nonatomic, setter = setPrevView:) UIView *prevView;
@property (nonatomic, setter = setNextView:) UIView *nextView;

@property (nonatomic, setter = setParentViewController:) UIViewController *mParentViewController;
@property (nonatomic, setter = setPrevNotification:) NSString *prevNotification;
@property (nonatomic, setter = setNextNotification:) NSString *nextNotification;

@property (nonatomic, assign) id<MHTextViewDelegate> textViewDelegate;

- (BOOL) validate;

@end
