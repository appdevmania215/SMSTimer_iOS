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

#import "CustomDialog.h"

//#define ENABLE_ROUNDED_DIALOGS

@interface CustomDialog()

@property (nonatomic, strong) UIView* backgroundView;

@end

@implementation CustomDialog

- (id)initWithNibName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:136.0/255.0];
        [self addSubview:_backgroundView];

        NSArray* array = [[NSBundle mainBundle] loadNibNamed:name
                                                       owner:self
                                                     options:nil];
        
        self.contentView = [array objectAtIndex:0];
        
#ifdef ENABLE_ROUNDED_DIALOGS
        [self.contentView.layer setCornerRadius:8.0];
        self.contentView.layer.masksToBounds = YES;
        
        [self.contentView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [self.contentView.layer setBorderWidth:1.5];
#endif
        _fullscreen = NO;
        _dimmBackground = YES;
        self.alpha = 0.0;
        self.hidden = YES;
    }
    return self;
}

- (void)show
{
    if (!_dimmBackground) {
        _backgroundView.hidden = YES;
    }
    
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];

    [window addSubview:self];
    self.frame = window.bounds;
    
    self.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.alpha = 1.0;
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^(void) {
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if(finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)setContentView:(UIView *)view
{
    [_contentView removeFromSuperview];
    _contentView = view;
    [self addSubview:view];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    _backgroundView.frame = self.bounds;
    
    if (_fullscreen) {
        CGFloat top = 0.0;
        if (SYSTEM_VERSION_GREATER_EQUAL(@"7.0")) {
            top = 20.0;
        }
        CGRect r = self.bounds;
        r.origin.y = top;
        r.size.height -= top;
        _contentView.frame = r;
    } else {
        CGSize size = self.bounds.size;
        CGSize cSize = _contentView.frame.size;
        
        CGFloat x = size.width/2 - cSize.width/2;
        CGFloat y = size.height/2 - cSize.height/2;
        _contentView.frame = CGRectMake(x, y, cSize.width, cSize.height);
    }
}

@end
