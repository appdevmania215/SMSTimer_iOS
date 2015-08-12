//
//  ComposeScheduleDateTableViewCell.m
//  TextTimer
//
//  Created by admin on 6/18/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "ComposeScheduleDateTableViewCell.h"
#import "Constants.h"

@implementation ComposeScheduleDateTableViewCell

@synthesize isEditable;
@synthesize lblScheduleDate;
@synthesize lblSeparateLine;
@synthesize ivDateIcon;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ( isEditable != YES ) {
        [lblSeparateLine setHidden:YES];
        [ivDateIcon setHidden:YES];
    }
    else {
        [lblSeparateLine setHidden:NO];
        [ivDateIcon setHidden:NO];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Touch Event
-(void)setup {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.btnScheduleDateView addGestureRecognizer:tap];
}

-(void)handleTap:(UITapGestureRecognizer *)recognizer {
    if ( isEditable == YES )
	    [[NSNotificationCenter defaultCenter] postNotificationName:ComposeDatePickerShow object:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ( isEditable == YES ) {
        UITouch *touch = [touches anyObject];
        if ( touch.view == self.btnScheduleDateView ) {
            self.btnScheduleDateView.layer.opacity = 0.5;
            self.btnScheduleDateView.layer.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ( touch.view == self.btnScheduleDateView ) {
        self.btnScheduleDateView.layer.opacity = 1;
        self.btnScheduleDateView.layer.backgroundColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    }
}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ( touch.view == self.btnScheduleDateView ) {
        self.btnScheduleDateView.layer.opacity = 1;
        self.btnScheduleDateView.layer.backgroundColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    }
}

@end
