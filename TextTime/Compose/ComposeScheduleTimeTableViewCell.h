//
//  ComposeScheduleTimeTableViewCell.h
//  TextTimer
//
//  Created by admin on 6/18/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeScheduleTimeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *btnScheduleTimeView;
@property (weak, nonatomic) IBOutlet UILabel *lblScheduleTime;
@property (weak, nonatomic) IBOutlet UIImageView *ivTimeIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblSeparateLine;

@property(nonatomic, setter = setEditable:) BOOL isEditable;

@end
