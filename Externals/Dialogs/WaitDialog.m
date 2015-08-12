/*
 *********************************************************************************
 *
 * Copyright (C) 2013-2014 T Dispatch Ltd
 *
 * See the LICENSE for terms and conditions of use, modification and distribution
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 *********************************************************************************
 *
 * @author Marcin Orlowski <marcin.orlowski@webnet.pl>
 *
 *********************************************************************************
 */

#import "WaitDialog.h"

@interface WaitDialog()

@property (weak, nonatomic) IBOutlet UILabel *waitLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation WaitDialog

- (id)init
{
    self = [super initWithNibName:@"WaitDialog"];
    if (self) {
    }
    return self;
}

- (void)show
{
    self.contentView.backgroundColor = [UIColor dialogDefaultBackgroundColor];
    
    _waitLabel.font = [UIFont lightOpenSansOfSize:20];
    _waitLabel.text = NSLocalizedString(@"tdfragment_please_wait", @"");
    _waitLabel.textColor = [UIColor buttonTextColor];
    
    [_activityIndicator startAnimating];
    
    [super show];
}

@end
