//
//  HowTosViewController.h
//  TextTimer
//
//  Created by admin on 6/17/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HowTosViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *howTosTableView;

@end
