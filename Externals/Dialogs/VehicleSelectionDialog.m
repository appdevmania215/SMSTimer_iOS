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

#import "VehicleSelectionDialog.h"
#import "VehicleSelectionViewCell.h"

@interface VehicleSelectionDialog() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *header;
@property (weak, nonatomic) IBOutlet FlatButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) NSArray* vehicles;
@property (weak, nonatomic) NSNumber* maxLuggage;
@property (weak, nonatomic) NSNumber* maxPassengers;

- (IBAction)cancelButtonPressed:(id)sender;

@property (nonatomic, copy) VehicleSelectionCompletionBlock completionBlock;

@end

@implementation VehicleSelectionDialog

- (id)init
{
    self = [super initWithNibName:@"VehicleSelectionDialog"];
    if (self) {
        [_cancelButton setTitle:NSLocalizedString(@"new_booking_dialog_picker_button_cancel", @"") forState:UIControlStateNormal];
        // Initialization code
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _vehicles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Vehicle *v = _vehicles[indexPath.row];

    VehicleSelectionViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"VehicleSelectionViewCell"];

    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.separatorView.backgroundColor = [UIColor tableSeparatorColor];

    if (v.maxPassengers.integerValue < _maxPassengers.integerValue ||
        v.maxLuggage.integerValue < _maxLuggage.integerValue) {
        cell.vehicleName.textColor = [UIColor lightGrayColor];
        cell.passengersLabel.textColor = [UIColor lightGrayColor];
        cell.luggageLabel.textColor = [UIColor lightGrayColor];
        cell.lockedImageView.hidden = NO;
    } else {
        cell.vehicleName.textColor = [UIColor buttonTextColor];
        cell.passengersLabel.textColor = [UIColor buttonTextColor];
        cell.luggageLabel.textColor = [UIColor buttonTextColor];
        cell.lockedImageView.hidden = YES;
    }
    
    cell.vehicleName.text = v.name;
    cell.vehicleName.font = [UIFont lightOpenSansOfSize:17];
    
    cell.passengersLabel.text = [v.maxPassengers stringValue];
    cell.passengersLabel.font = [UIFont lightOpenSansOfSize:17];

    cell.luggageLabel.text = [v.maxLuggage stringValue];
    cell.luggageLabel.font = [UIFont lightOpenSansOfSize:17];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Vehicle *v = _vehicles[indexPath.row];

    if (v.maxLuggage.integerValue >= _maxLuggage.integerValue && v.maxPassengers.integerValue >= _maxPassengers.integerValue) {
    
        if (_completionBlock) {
            NSLog(@"Selected vehicle: %@", v);
            _completionBlock(v);
        }
        [self dismiss];
    }
}

+ (void)selectVehicleFromList:(NSArray*)vehicles
                    maxLuggge:(NSNumber *)maxLuggage
                maxPassengers:(NSNumber *)maxPassengers
           preselectedVehicle:(Vehicle*)vehicle
              completionBlock:(VehicleSelectionCompletionBlock)completionBlock
{
    VehicleSelectionDialog* d = [[VehicleSelectionDialog alloc] init];
    d.vehicles = vehicles;
    d.completionBlock = completionBlock;
    d.maxPassengers = maxPassengers;
    d.maxLuggage = maxLuggage;
    [d show];
}

- (void)show {
    self.contentView.backgroundColor = [UIColor dialogDefaultBackgroundColor];
    
    UINib *nib = [UINib nibWithNibName:@"VehicleSelectionViewCell" bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:@"VehicleSelectionViewCell"];
    
    if (!IS_IPAD) {
        self.dimmBackground = NO;
        self.fullscreen = YES;
    }

    [_header setTitle:NSLocalizedString(@"vehicle_selector_title", @"") forState:UIControlStateNormal];
    [_header.titleLabel setFont:[UIFont lightOpenSansOfSize:19]];
    [_header setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
    [_header setBackgroundColor:[UIColor buttonColor]];
    
    [_cancelButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
    [_cancelButton setTitle:NSLocalizedString(@"vehicle_selector_button_cancel", @"") forState:UIControlStateNormal];
    
    [super show];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismiss];
}

@end
