//
//  ComposeActionTableViewCell.h
//  TextTimer
//
//  Created by admin on 6/18/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ComposeActionTableViewCell;
@protocol ComposeActionTableViewCellDelegate <NSObject>

- (void) trashScheduleInCell:(ComposeActionTableViewCell *)cell;
- (void) editScheduleInCell:(ComposeActionTableViewCell *)cell;

@end

@interface ComposeActionTableViewCell : UITableViewCell

@property (weak, nonatomic) id<ComposeActionTableViewCellDelegate> delegate;

@end
