//
//  HowTosViewController.m
//  TextTimer
//
//  Created by admin on 6/17/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "HowTosViewController.h"
#import "HomeTableViewCell.h"

@interface HowTosViewController ()

@end

@implementation HowTosViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [indexPath row] == 0 ) {
        static NSString *cellIdentifier1 = @"howTosTitleCell";
        HomeTableViewCell *cell = (HomeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        return cell;
    }
    else if ( [indexPath row] == 1 ) {
        static NSString *cellIdentifier2 = @"howTosSubTitleCell";
        HomeTableViewCell *cell = (HomeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        return cell;
    }
    else if ( [indexPath row] == 2 ) {
        static NSString *cellIdentifier3 = @"howTosContentCell";
        HomeTableViewCell *cell = (HomeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
        return cell;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ( [indexPath row] == 0 ) {
        return 70.0f;
    }
    else {
        HomeTableViewCell *cell = nil;
        if ( [indexPath row] == 1 ) {
            static NSString *cellIdentifier2 = @"howTosSubTitleCell";
            cell = (HomeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        }
        else if ( [indexPath row] == 2 ) {
            static NSString *cellIdentifier3 = @"howTosContentCell";
            cell = (HomeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier3];
        }

        [cell.contentView layoutSubviews];
        
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
 
        if ( UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            height = height * (self.view.frame.size.height / self.view.frame.size.width + 0.05);
        }
        return height;
        
    }
}


@end
