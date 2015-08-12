//
//  ComposeMessageTableViewCell.h
//  TextTimer
//
//  Created by admin on 6/18/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DemoTextView;

@interface ComposeMessageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet DemoTextView *tvMessage;

@property(nonatomic, setter = setEditable:) BOOL isEditable;

@end
