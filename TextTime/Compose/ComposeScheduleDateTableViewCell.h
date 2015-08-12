//
//  ComposeScheduleDateTableViewCell.h
//  TextTimer
//
//  Created by admin on 6/18/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeScheduleDateTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblScheduleDate;
@property (weak, nonatomic) IBOutlet UIView *btnScheduleDateView;
@property (weak, nonatomic) IBOutlet UIImageView *ivDateIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblSeparateLine;

@property(nonatomic, setter = setEditable:) BOOL isEditable;

-(void)setup;
-(void)handleTap:(UITapGestureRecognizer *)recognizer;

@end
