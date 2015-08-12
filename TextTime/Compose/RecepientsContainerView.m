//
//  RecepientsContainerView.m
//  TextTimer
//
//  Created by admin on 6/19/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "RecepientsContainerView.h"
#import "Contact.h"
#import "RecepientTagView.h"
#import "ComposeViewController.h"

#import "../Constants.h"

@implementation RecepientsContainerView

@synthesize recepientsArray;
@synthesize isEditable;
@synthesize mParentViewController;

static CGFloat padding = 6;
static CGFloat tagPadding = 2;
static CGFloat iconWidth = 47.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (void) awakeFromNib{
    [super awakeFromNib];
    [self setup];
}

- (void) setup {
    nextX = padding;
    nextY = padding;
    nextHeight = 0;
    [self getMaxWidth];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//
//}

- (void) getMaxWidth {
    maxWidth = self.frame.size.width;
    if ( isEditable )
        maxWidth -= iconWidth;
}
- (CGFloat) getSize {
    if ( recepientsArray == nil || [recepientsArray count] == 0 )
        return 45;
    
    return nextY + nextHeight + padding;
}

- (CGFloat) addRecepient:(Contact*)contact {
    [self getMaxWidth];
    RecepientTagView *tagView = [[RecepientTagView alloc] init];
    [tagView setContact:contact];
    [tagView setParent:self];
    [tagView setIndex:[recepientsArray count]];
    
    if ( recepientsArray == nil )
        recepientsArray = [[NSMutableArray alloc] init];
    [recepientsArray addObject:tagView];
    
    return [self displayRecepient:tagView];
}

- (void) deleteRecepient:(RecepientTagView*)tagView {
    [mParentViewController removeRecepient:tagView.mContact];
    [recepientsArray removeObject:tagView];
    [tagView removeFromSuperview];
    tagView = nil;
    [self reloadRecepients];
}

- (CGFloat) displayRecepient:(RecepientTagView*)tagView {
    CGSize tagSize = [tagView getSize];
    if ( maxWidth < nextX + tagSize.width - padding) {
        nextX = padding + tagPadding;
        nextY += nextHeight + tagPadding;
        nextHeight = 0;
    }
    else {
        nextX += tagPadding;
    }
    if ( tagSize.height > nextHeight ) {
        nextHeight = tagSize.height;
    }
    tagView.frame = CGRectMake(nextX, nextY, tagSize.width, tagSize.height);
    [self addSubview:tagView];
    
    nextX += tagSize.width;
    
    return nextY + nextHeight + padding;
}

-(void) reloadRecepients {
    [self setup];
    [UIView animateWithDuration:0.25f
                     animations:^{
                         for ( int i = 0; i < [recepientsArray count]; i++ ) {
                             [self displayRecepient:recepientsArray[i]];
                         }
                     }
                     completion:^(BOOL finished){
                         if ( mParentViewController ) {
                             [mParentViewController.tableView reloadData];
                         }
                         else
	                         [[NSNotificationCenter defaultCenter] postNotificationName:ComposeUpdateRecepients object:self];
                     }];
}

- (void) dealloc {
    [recepientsArray removeAllObjects];
}

@end
