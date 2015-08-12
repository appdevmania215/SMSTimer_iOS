//
//  CustomButton.m
//  TextTime
//
//  Created by admin on 6/10/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

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
        _isCorner = NO;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CALayer *layer = self.layer;
    if ( _isCorner == YES ) {
        layer.cornerRadius = 5.0f;
        layer.shadowColor = [[UIColor blackColor] CGColor];
        layer.shadowRadius = 5.0f;
        layer.masksToBounds = YES;
    }
    if ( self.selected || self.highlighted ) {
        layer.opacity = 0.5f;
    }
    else {
        layer.opacity = 1.0f;
    }
}

-(void) setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self setNeedsDisplay];
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}
@end
