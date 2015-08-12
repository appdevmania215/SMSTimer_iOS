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

#import "DatePickerDialog.h"

@interface DatePickerDialog()

@property (weak, nonatomic) IBOutlet UIDatePicker *picker;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)selectButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@property (nonatomic, copy) DatePickerCompletionBlock completionBlock;

@end


@implementation DatePickerDialog

- (id)init
{
    self = [super initWithNibName:@"DatePickerDialog"];
    if (self) {
        
        [_selectButton setTitle:NSLocalizedString(@"new_booking_dialog_picker_button_select", @"") forState:UIControlStateNormal];
        [_cancelButton setTitle:NSLocalizedString(@"new_booking_dialog_picker_button_cancel", @"") forState:UIControlStateNormal];
        // Initialization code
    }
    return self;
}

+ (void)showTimePicker:(DatePickerCompletionBlock)completionBlock withMinimumDate:(NSDate *)date
{
    DatePickerDialog* d = [[DatePickerDialog alloc] init];
    d.picker.datePickerMode = UIDatePickerModeTime;

    d.picker.minimumDate = date;
    d.completionBlock = completionBlock;
    [d show];
}

+ (void)showDatePicker:(DatePickerCompletionBlock)completionBlock ignoreMaxDaysAhead:(BOOL)ignoreMaxDaysAhead
{
    DatePickerDialog* d = [[DatePickerDialog alloc] init];
    d.picker.datePickerMode = UIDatePickerModeDate;
    
    if (!ignoreMaxDaysAhead) {
        NSDate* maxDate = [NSDate date];
        NSInteger maxDaysAhead = [CabOfficeSettings newBookingsMaxDaysAhead];
        maxDate = [maxDate dateByAddingTimeInterval:maxDaysAhead*24*60*60];
        d.picker.maximumDate = maxDate;
    }
    
    d.picker.minimumDate = [NSDate date];
    d.completionBlock = completionBlock;
    [d show];
}

- (IBAction)selectButtonPressed:(id)sender {
    
    NSLog(@"selected date: %@", _picker.date);
    
    if (_completionBlock)
        _completionBlock(_picker.date);
    [self dismiss];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismiss];
}
@end
