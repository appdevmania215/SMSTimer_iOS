//
//  TabView.m
//  TextTime
//
//  Created by admin on 6/9/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "TabView.h"
#import "ScheduleViewController.h"
#import "Constants.h"
#import "ViewController.h"

@implementation TabView {
    int _currentTab;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setTab:_currentTab];
        [self setNotificationManager];
    }
    return self;
}

- (void) awakeFromNib{
    [super awakeFromNib];
    [self setTab:_currentTab];
    [self setNotificationManager];
}

-(id)init {
    self = [super init];
    if (self) {
        // Initialization code
        [self setTab:_currentTab];
        [self setNotificationManager];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if ( _currentTab ) {
        UIButton *button = (UIButton *)[self viewWithTag:_currentTab];
        [_shadowLabel setFrame:CGRectMake(button.frame.origin.x, 40, button.frame.size.width, 2)];
    }
//        [self setTab:_currentTab];
}
#pragma mark - Notification

- (void) setNotificationManager {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:SetScheduleTabViewNotification object:nil];
}

- (void) receiveNotification:(NSNotification *)notification {
    if ( [[notification name] isEqualToString:SetScheduleTabViewNotification] ) {
        NSDictionary *data = [notification userInfo];
        if ( data != nil ) {
            int number = [[data objectForKey:TAB_NUMBER] intValue];
            [self setTab:number + 100];
        }
    }
}

-(void)postNotification:(NSString*)index {
    NSDictionary *data = [NSDictionary dictionaryWithObject:index forKey:TAB_NUMBER];
    [[NSNotificationCenter defaultCenter] postNotificationName:SetScheduleTabNotification object:self userInfo:data];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SetScheduleTabNotification object:nil];
}

#pragma mark - Button Action

- (IBAction)setTabAll:(id)sender {
    [self setTabButton:sender];
}
- (IBAction)setTabScheduled:(id)sender {
    [self setTabButton:sender];
}
- (IBAction)setTabSent:(id)sender {
    [self setTabButton:sender];
}

-(void)setTabButton:(id)sender {
    if ( self.parentViewController != nil ) {
        [self.parentViewController.scheduleViewController jumpToTab:((UIButton*)sender).tag - 100];
    }
    [self setTab:((UIButton*)sender).tag];
}
-(void)setTab {
    [self setTab:_currentTab];
}
-(void) setTab:(long) tab {
    if ( !tab)
        tab = SCHEDULED;
    UIButton *button = (UIButton *)[self viewWithTag:tab];
    [UIView animateWithDuration:0.5f animations:^{
        
        [_shadowLabel setFrame:CGRectMake(button.frame.origin.x, 40, button.frame.size.width, 2)];
        
    } completion:^(BOOL finished) {
        if (finished) {
            if (!button.selected) {
                button.selected = YES;
                if ( _currentTab ) {
                    UIButton *oldbutton = (UIButton *)[self viewWithTag:_currentTab];
                    oldbutton.selected = NO;
                }
                _currentTab = (int)
                button.tag;
            }
            [self layoutIfNeeded];
            [_shadowLabel setFrame:CGRectMake(button.frame.origin.x, 40, button.frame.size.width, 2)];
            [self layoutIfNeeded];
        }
    }];
    
}

@end
