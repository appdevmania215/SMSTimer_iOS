//
//  ComposeRecepientsTableViewCell.m
//  TextTimer
//
//  Created by admin on 6/18/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "ComposeRecepientsTableViewCell.h"
#import "../Constants.h"

@implementation ComposeRecepientsTableViewCell

@synthesize isEditable;
@synthesize lblSeparateLine;
@synthesize btnRecepients;

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
        [btnRecepients setHidden:YES];
    }
    else {
        [lblSeparateLine setHidden:NO];
        [btnRecepients setHidden:NO];
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
    [self.btnRecepients addGestureRecognizer:tap];
}

-(void)handleTap:(UITapGestureRecognizer *)recognizer {
    if ( isEditable == YES )
	    [[NSNotificationCenter defaultCenter] postNotificationName:ComposeContactPickerShow object:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ( isEditable == YES ) {
        UITouch *touch = [touches anyObject];
        if ( touch.view == self.btnRecepients ) {
            self.btnRecepients.layer.opacity = 0.5;
            self.btnRecepients.layer.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1].CGColor;
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ( touch.view == self.btnRecepients ) {
        self.btnRecepients.layer.opacity = 1;
        self.btnRecepients.layer.backgroundColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    }
}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ( touch.view == self.btnRecepients ) {
        self.btnRecepients.layer.opacity = 1;
        self.btnRecepients.layer.backgroundColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    }
}


@end
