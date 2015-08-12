//
//  MHTextView.m
//
//  Created by Mehfuz Hossain on 4/11/13.
//  Copyright (c) 2013 Mehfuz Hossain. All rights reserved.
//

#import "MHTextView.h"

NSString * const UITextViewTextShouldBeginEditingNotification = @"textViewShouldBeginEditingNotification";

@interface MHTextView()
{
    UITextView *_textView;
    BOOL _disabled;
    CGFloat scrollOffset;
}

@property (nonatomic) BOOL keyboardIsShown;
@property (nonatomic) CGSize keyboardSize;
@property (nonatomic) BOOL hasSuperScrollView;
@property (nonatomic) BOOL invalid;

@property (nonatomic, setter = setToolbarCommand:) BOOL isToolBarCommand;
@property (nonatomic, setter = setDoneCommand:) BOOL isDoneCommand;

@property (nonatomic , strong) UIBarButtonItem *previousBarButton;
@property (nonatomic , strong) UIBarButtonItem *nextBarButton;

@property (nonatomic, strong) NSMutableArray *textViews;

@end

@implementation MHTextView

@synthesize required;
@synthesize superScrollView;
@synthesize toolbar;
@synthesize keyboardIsShown;
@synthesize keyboardSize;
@synthesize invalid;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self){
        [self setup];
    }
    
    return self;
}

- (void) awakeFromNib{
    [super awakeFromNib];
    [self setup];
}

- (void)setup
{
    [self setTintColor:[UIColor blackColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewShouldBeginEditing:) name: UITextViewTextShouldBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:self];
    
    toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.window.frame.size.width, 44);
    // set style
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    
    self.previousBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Previous" style:UIBarButtonItemStyleBordered target:self action:@selector(previousButtonIsClicked:)];
    self.nextBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButtonIsClicked:)];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonIsClicked:)];
    
    NSArray *barButtonItems = @[self.previousBarButton, self.nextBarButton, flexBarButton, doneBarButton];
    
    toolbar.items = barButtonItems;
    
    self.textViews = [[NSMutableArray alloc]init];
    
    [self marktextViewsWithTagInView:self.superview];
}

- (void)marktextViewsWithTagInView:(UIView*)view
{
    int index = 0;
    if ([self.textViews count] == 0){
        for(UIView *subView in view.subviews){
            if ([subView isKindOfClass:[MHTextView class]]){
                MHTextView *textView = (MHTextView*)subView;
                textView.tag = index;
                [self.textViews addObject:textView];
                index++;
            }
            else if ( [subView isKindOfClass:[UITextField class]]){
                UITextField *textField = (UITextField*)subView;
                textField.tag = index;
                [self.textViews addObject:textField];
                index++;
            }
        }
    }
}

- (void) doneButtonIsClicked:(id)sender
{
    [self setDoneCommand:YES];
    [self resignFirstResponder];
    [self setToolbarCommand:YES];
}

-(void) keyboardDidShow:(NSNotification *) notification
{
    if (_textView == nil) return;
    if (keyboardIsShown) return;
    if (!([_textView isKindOfClass:[MHTextView class]] || [_textView isKindOfClass:[UITextField class]])) return;
    
    NSDictionary* info = [notification userInfo];
    
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardSize = [aValue CGRectValue].size;
    
    [self scrollToField];
    
    self.keyboardIsShown = YES;
    
}

-(void) keyboardWillHide:(NSNotification *) notification
{
    NSTimeInterval duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        if (_isDoneCommand) {
            CGFloat height =  superScrollView.scrollIndicatorInsets.bottom - superScrollView.scrollIndicatorInsets.top;
            scrollOffset = height - superScrollView.frame.size.height;
            if ( scrollOffset < superScrollView.contentOffset.y )
                [self.superScrollView setContentOffset:CGPointMake(0, scrollOffset) animated:NO];
        }
    }];
    
    keyboardIsShown = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:self];
}


- (void) nextButtonIsClicked:(id)sender
{
    if ( _nextView ) {
        [self becomeTextViewActive:(MHTextView*)_nextView];
    }
    else if ( _nextNotification ) {
        [self setDoneCommand:YES];
        [self resignFirstResponder];
        [[NSNotificationCenter defaultCenter] postNotificationName:_nextNotification object:_mParentViewController];
    }
    else {
        NSInteger tagIndex = self.tag + 1;
        if ( [[self.textViews objectAtIndex:tagIndex] isKindOfClass:[MHTextView class]]) {
            MHTextView *textView =  [self.textViews objectAtIndex:tagIndex];
            
            //        while (!textField.isEnabled && tagIndex < [self.textViews count])
            //            textField = [self.textViews objectAtIndex:++tagIndex];
            
            [self becomeTextViewActive:textView];
        }
        else if ( [[self.textViews objectAtIndex:tagIndex] isKindOfClass:[UITextField class]] ) {
            UITextField *textField =  [self.textViews objectAtIndex:tagIndex];
            
            //        while ( tagIndex < [self.textViews count])
            //            textField = [self.textViews objectAtIndex:++tagIndex];
            
            [self becomeActive:textField];
        }
    }
}

- (void) previousButtonIsClicked:(id)sender
{
    if ( _prevView ) {
        [self becomeTextViewActive:(MHTextView*)_prevView];
    }
    else if ( _prevNotification ) {
        [self setDoneCommand:YES];
        [self resignFirstResponder];
        [[NSNotificationCenter defaultCenter] postNotificationName:_prevNotification object:_mParentViewController];
    }
    else {
        NSInteger tagIndex = self.tag - 1;
        if ( [[self.textViews objectAtIndex:tagIndex] isKindOfClass:[MHTextView class]]) {
            MHTextView *textView =  [self.textViews objectAtIndex:tagIndex];
            
            //        while (!textField.isEnabled && tagIndex < [self.textViews count])
            //            textField = [self.textViews objectAtIndex:--tagIndex];
            
            [self becomeTextViewActive:textView];
        }
        else if ( [[self.textViews objectAtIndex:tagIndex] isKindOfClass:[UITextField class]] ) {
            UITextField *textField =  [self.textViews objectAtIndex:tagIndex];
            
            //        while ( tagIndex < [self.textViews count])
            //            textField = [self.textViews objectAtIndex:--tagIndex];
            
            [self becomeActive:textField];
        }
    }
}

- (void)becomeActive:(UITextField*)textField
{
    [self setToolbarCommand:YES];
    [self resignFirstResponder];
    [textField becomeFirstResponder];
}

- (void)becomeTextViewActive:(UITextView*)textView
{
    [self setToolbarCommand:YES];
    [self resignFirstResponder];
    [textView becomeFirstResponder];
}

- (void)setBarButtonNeedsDisplayAtTag:(NSInteger)tag
{
    BOOL previousBarButtonEnabled = NO;
    BOOL nexBarButtonEnabled = NO;
    
//    for (int index = 0; index < [self.textViews count]; index++) {
//        
//        UITextField *textField = [self.textViews objectAtIndex:index];
//        
//        if (index < tag)
//            previousBarButtonEnabled |= textField.isEnabled;
//        else if (index > tag)
//            nexBarButtonEnabled |= textField.isEnabled;
//    }
    if ( [self.textViews count] > 0 && tag > 0 )
        previousBarButtonEnabled = YES;
    if ( [self.textViews count] > 0 && tag < [self.textViews count] - 1 )
        nexBarButtonEnabled = YES;
    
    if ( _nextView && _nextNotification )
        nexBarButtonEnabled = YES;
    
    if ( _prevView && _prevNotification )
        previousBarButtonEnabled = YES;
    
    self.previousBarButton.enabled = previousBarButtonEnabled;
    self.nextBarButton.enabled = nexBarButtonEnabled;
}

- (void)datePickerValueChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    [datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    
    NSDate *selectedDate = datePicker.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [
     dateFormatter setDateFormat:@"dd MM, HH:mm"];
    
    [_textView setText:[dateFormatter stringFromDate:selectedDate]];
    
    [self validate];
}

- (void)scrollToField
{
    CGRect textFieldRect = _textView.frame;
    if ( _topHeight ) {
        textFieldRect.origin.y += _topHeight;
    }
    CGRect aRect = self.window.bounds;
    
    aRect.origin.y = -superScrollView.contentOffset.y;
    aRect.size.height -= keyboardSize.height + self.toolbar.frame.size.height;
    
    CGPoint textRectBoundary = CGPointMake(textFieldRect.origin.x, textFieldRect.origin.y + textFieldRect.size.height);
    if (!CGRectContainsPoint(aRect, textRectBoundary) || superScrollView.contentOffset.y > 0) {
        CGPoint scrollPoint = CGPointMake(0.0, self.superview.frame.origin.y + textFieldRect.origin.y + _textView.frame.size.height - aRect.size.height);
        
        if (scrollPoint.y < 0) scrollPoint.y = 0;
        [superScrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (BOOL) validate
{
    CALayer *layer = self.layer;
    if ( _isValidView )
	    [layer setBorderColor: [UIColor colorWithRed:255 green:0 blue:0 alpha:0.5].CGColor];
    
    if (required && [self.text isEqualToString:@""]){
        return NO;
    }
    
    if ( _isValidView )
	    [layer setBorderColor: [UIColor colorWithWhite:0.1 alpha:0.2].CGColor];
    //    [self setBackgroundColor:[UIColor whiteColor]];
    
    return YES;
}

#pragma mark - UITextView notifications
- (void)textViewShouldBeginEditing:(NSNotification *) notification
{
    NSLog(@"textViewDidBeginEditing");
    if ( [[notification object] isKindOfClass:[UITextView class]] ) {
        UITextView *textView = (UITextView*)[notification object];
        
        _textView = textView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [self setBarButtonNeedsDisplayAtTag:textView.tag];
        
        if ([self.superview isKindOfClass:[UIScrollView class]] && self.superScrollView == nil)
            self.superScrollView = (UIScrollView*)self.superview;
        
        [self setInputAccessoryView:toolbar];
        
        [self setDoneCommand:NO];
        [self setToolbarCommand:NO];
    }
}

- (void)textViewDidEndEditing:(NSNotification *) notification
{
    NSLog(@"textViewDidEndEditing");
    if ( [[notification object] isKindOfClass:[UITextField class]] ) {
        
        [self validate];
        
        _textView = nil;
        
    }
}

@end
