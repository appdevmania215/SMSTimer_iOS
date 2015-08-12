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

#import "CardSelectionDialog.h"

@interface CardSelectionDialog() <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet FlatButton *selectButton;
@property (weak, nonatomic) IBOutlet FlatButton *cancelButton;

@property (weak, nonatomic) NSArray* cards;

- (IBAction)selectButtonPresed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@property (nonatomic, copy) CardSelectionCompletionBlock completionBlock;

@end

@implementation CardSelectionDialog

- (id)init
{
    self = [super initWithNibName:@"CardSelectionDialog"];
    if (self) {
        
        [_selectButton setTitle:NSLocalizedString(@"new_booking_dialog_picker_button_select", @"") forState:UIControlStateNormal];
        [_cancelButton setTitle:NSLocalizedString(@"new_booking_dialog_picker_button_cancel", @"") forState:UIControlStateNormal];
        // Initialization code
    }
    return self;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _cards.count;
}

#define ROW_HEIGHT 42
#define ROW_MARGIN 0
#define ROW_LABEL_HEIGHT 21

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return ROW_HEIGHT;
}

- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0,0,thePickerView.frame.size.width,ROW_HEIGHT)];
    
    CreditCard *c = _cards[row];

    UILabel* holder = [[UILabel alloc] initWithFrame:CGRectMake(0,ROW_MARGIN,thePickerView.frame.size.width, ROW_LABEL_HEIGHT)];
    holder.text = c.cardholderName;
    holder.textAlignment = NSTextAlignmentCenter;
    holder.backgroundColor = [UIColor clearColor];
    holder.font = [UIFont lightOpenSansOfSize:16];
    holder.textColor = [UIColor blackColor];
    [v addSubview:holder];
    
    UILabel* number = [[UILabel alloc] initWithFrame:CGRectMake(0,ROW_MARGIN+ROW_LABEL_HEIGHT,thePickerView.frame.size.width, ROW_LABEL_HEIGHT)];
    number.text = c.maskedNumber;
    number.textAlignment = NSTextAlignmentCenter;
    number.backgroundColor = [UIColor clearColor];
    number.font = [UIFont lightOpenSansOfSize:16];
    number.textColor = [UIColor blackColor];
    [v addSubview:number];
    
    return v;
}


+ (void)selectCardFromList:(NSArray*)cards
           preselectedCard:(CreditCard*)card
           completionBlock:(CardSelectionCompletionBlock)completionBlock
{
    CardSelectionDialog* d = [[CardSelectionDialog alloc] init];
    d.cards = cards;
    d.completionBlock = completionBlock;
    NSInteger idx = [cards indexOfObject:card];
    [d.pickerView selectRow:idx inComponent:0 animated:NO];
    [d show];
}

- (IBAction)selectButtonPresed:(id)sender {
    if (_completionBlock) {
        CreditCard *c = _cards[[_pickerView selectedRowInComponent:0]];
        _completionBlock(c);
    }
    [self dismiss];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismiss];
}

@end
