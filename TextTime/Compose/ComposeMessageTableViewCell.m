//
//  ComposeMessageTableViewCell.m
//  TextTimer
//
//  Created by admin on 6/18/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "ComposeMessageTableViewCell.h"
#import "../../Externals/InputField/DemoTextView.h"

@implementation ComposeMessageTableViewCell

@synthesize isEditable;
@synthesize tvMessage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ( isEditable == YES ) {
        [tvMessage setEditable:YES];
    }
    else {
        [tvMessage setEditable:NO];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
