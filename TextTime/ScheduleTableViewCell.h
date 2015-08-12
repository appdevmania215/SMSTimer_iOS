//
//  ScheduleTableViewCell.h
//  TextTime
//
//  Created by admin on 6/10/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblRecepientName;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblRemainingDateTime;
@property (weak, nonatomic) IBOutlet UILabel *lblReservationDateTime;

@end
