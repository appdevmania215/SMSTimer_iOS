//
//  ComposeRecepientsTableViewCell.h
//  TextTimer
//
//  Created by admin on 6/18/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecepientsContainerView;

@interface ComposeRecepientsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet RecepientsContainerView *recepientsView;
@property (weak, nonatomic) IBOutlet UIView *btnRecepients;
@property (weak, nonatomic) IBOutlet UILabel *lblSeparateLine;

@property(nonatomic, setter = setEditable:) BOOL isEditable;

@end
