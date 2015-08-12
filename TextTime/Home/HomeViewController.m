//
//  HomeViewController.m
//  TextTimer
//
//  Created by admin on 6/16/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "HomeViewController.h"
#import "Constants.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

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

#pragma mark - Button Action

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)shareToSocial:(id)sender {
    NSArray *shareItems = [NSArray arrayWithObject:[NSString stringWithFormat:@"Download this great app at %@", ShareUrl]];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    [vc.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
