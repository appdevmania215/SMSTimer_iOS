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

#import "VehicleSelectionViewCell.h"

@implementation VehicleSelectionViewCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect r = _vehicleName.frame;
    if (_lockedImageView.hidden) {
        r.origin.x = 7;
        r.size.width = 239;
    } else {
        r.origin.x = 37;
        r.size.width = 209;
    }
    _vehicleName.frame = r;
}

@end
