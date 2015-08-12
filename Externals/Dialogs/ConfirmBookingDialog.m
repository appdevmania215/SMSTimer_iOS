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

#import "ConfirmBookingDialog.h"
#import "DatePickerDialog.h"
#import "VehicleSelectionDialog.h"
#import "NSDate+CabOfficeSettings.h"
#import "CreditCard.h"
#import "CreditCardsManager.h"
#import "CardSelectionDialog.h"
#import "BraintreeWrapperEngine.h"
#import "NoteDialog.h"
#import "NSDate+CustomFormatter.h"

@interface ConfirmBookingDialog()
{
    NSTimer* _pickupTimer;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *header;
@property (weak, nonatomic) IBOutlet FlatButton *bookButton;
@property (weak, nonatomic) IBOutlet FlatButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *dropoffImageView;
@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *dropoffLabel;
@property (weak, nonatomic) IBOutlet FlatButton *timeButton;
@property (weak, nonatomic) IBOutlet FlatButton *dateButton;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *pickupView;
@property (weak, nonatomic) IBOutlet UIView *dropoffView;
@property (weak, nonatomic) IBOutlet UIView *vehicleView;
@property (weak, nonatomic) IBOutlet UIView *passengersView;
@property (weak, nonatomic) IBOutlet UIView *notesView;
@property (weak, nonatomic) IBOutlet UILabel *luggageLabel;
@property (weak, nonatomic) IBOutlet UISlider *luggageSlider;
@property (weak, nonatomic) IBOutlet UILabel *passengersLabel;
@property (weak, nonatomic) IBOutlet UISlider *passengersSlider;
@property (weak, nonatomic) IBOutlet UIView *paymentView;
@property (weak, nonatomic) IBOutlet FlatButton *paymentCardButton;
@property (weak, nonatomic) IBOutlet FlatButton *paymentCashButton;

@property (weak, nonatomic) IBOutlet UIView *luggageView;
@property (weak, nonatomic) IBOutlet FlatButton *notesButton;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet FlatButton *vehicleButton;

@property (weak, nonatomic) IBOutlet FlatButton *laterButton;
@property (weak, nonatomic) IBOutlet FlatButton *nowButton;

@property (weak, nonatomic) MapAnnotation* pickup;
@property (weak, nonatomic) MapAnnotation* dropoff;
@property (weak, nonatomic) VehiclesManager* vehiclesManager;
@property (weak, nonatomic) Vehicle* selectedVehicle;
@property (weak, nonatomic) IBOutlet UIView *activityView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityViewIndicator;
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet FlatButton *cardButton;

@property (weak, nonatomic) CreditCard* selectedCard;

@property (strong, nonatomic) NSDate *selectedTime;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSString *paymentMethod;

@property (strong, nonatomic) NSString* notes;

- (IBAction)bookButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)timeButtonPressed:(id)sender;
- (IBAction)dateButtonPressed:(id)sender;
- (IBAction)vehicleButtonPressed:(id)sender;
- (IBAction)cardButtonPressed:(id)sender;
- (IBAction)nowButtonPressed:(id)sender;
- (IBAction)laterButtonPressed:(id)sender;
- (IBAction)notesButtonPressed:(id)sender;
- (IBAction)passengersSliderValueChanged:(id)sender;
- (IBAction)luggageSliderValueChanged:(id)sender;
- (IBAction)paymentCashButtonPressed:(id)sender;
- (IBAction)paymentCardButtonPressed:(id)sender;

@property (nonatomic, copy) DialogConfirmationBlock confirmationBlock;

@end

@implementation ConfirmBookingDialog

- (id)init
{
    self = [super initWithNibName:@"ConfirmBookingDialog"];
    if (self) {
    }
    return self;
}

+ (ConfirmBookingDialog*) showDialog:(MapAnnotation *)pickup
                             dropoff:(MapAnnotation *)dropoff
                 withVehiclesManager:(VehiclesManager *)vehiclesManager
                   confirmationBlock:(DialogConfirmationBlock)confirmationBlock

{
    ConfirmBookingDialog* dialog = [[ConfirmBookingDialog alloc] init];
    dialog.pickupLabel.text = pickup.title;
    
    dialog.vehiclesManager = vehiclesManager;
    dialog.pickup = pickup;
    dialog.dropoff = dropoff;
    
    if (dropoff) {
        dialog.dropoffView.hidden = NO;
        dialog.dropoffLabel.text = dropoff.title;
    } else {
        dialog.dropoffView.hidden = YES;
    }
    
    if (confirmationBlock) {
        dialog.confirmationBlock = confirmationBlock;
    }

    if (!IS_IPAD) {
        dialog.dimmBackground = NO;
        dialog.fullscreen = YES;
    }

    [dialog show];
    return dialog;
}

- (void)show
{
    UIFont *font = [UIFont semiboldOpenSansOfSize:17];
    
    self.contentView.backgroundColor = [UIColor dialogDefaultBackgroundColor];

    [self hideActivityView];
    _activityViewIndicator.center = _activityView.center;
    
    _priceLabel.backgroundColor = [UIColor lightGrayColor];
    _priceLabel.textColor = [UIColor blackColor];
    _priceLabel.font = [UIFont lightOpenSansOfSize:17];
    _priceLabel.text = @"";
    
    _pickupLabel.font = font;
    _pickupLabel.textColor = [UIColor pickupTextColor];
    
    _dropoffLabel.font = font;
    _dropoffLabel.textColor = [UIColor dropoffTextColor];
    
    [_paymentCardButton setTitleFont:[UIFont semiboldOpenSansOfSize:16]];
    [_paymentCardButton setTitleColor:[UIColor pickupTextColor] forState:UIControlStateNormal];
    [_paymentCardButton setTitle:NSLocalizedString(@"new_booking_dialog_payment_method_card", @"") forState:UIControlStateNormal];
    
    [_paymentCashButton setTitleFont:[UIFont semiboldOpenSansOfSize:16]];
    [_paymentCashButton setTitleColor:[UIColor pickupTextColor] forState:UIControlStateNormal];
    [_paymentCashButton setTitle:NSLocalizedString(@"new_booking_dialog_payment_method_cash", @"") forState:UIControlStateNormal];
    
    [_header setTitle:NSLocalizedString(@"new_booking_dialog_title", @"") forState:UIControlStateNormal];
    [_header.titleLabel setFont:[UIFont lightOpenSansOfSize:19]];
    [_header setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
    [_header setBackgroundColor:[UIColor buttonColor]];

    [_cancelButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
    [_cancelButton setTitle:NSLocalizedString(@"new_booking_dialog_button_cancel", @"") forState:UIControlStateNormal];
    
    [_bookButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
    [_bookButton setTitle:NSLocalizedString(@"new_booking_dialog_button_ok", @"") forState:UIControlStateNormal];
    
    [_timeButton setTitleFont:[UIFont semiboldOpenSansOfSize:16]];
    [_timeButton setTitleColor:[UIColor pickupTextColor] forState:UIControlStateNormal];

    [_dateButton setTitleFont:[UIFont semiboldOpenSansOfSize:16]];
    [_dateButton setTitleColor:[UIColor pickupTextColor] forState:UIControlStateNormal];

    [_nowButton setTitleFont:[UIFont semiboldOpenSansOfSize:16]];
    [_nowButton setTitleColor:[UIColor pickupTextColor] forState:UIControlStateNormal];
    [_nowButton setButtonBackgroundColor:[UIColor grayColor]];
    [_nowButton setTitle:NSLocalizedString(@"new_booking_dialog_pickup_time_now", @"") forState:UIControlStateNormal];

    [_laterButton setTitleFont:[UIFont semiboldOpenSansOfSize:16]];
    [_laterButton setTitleColor:[UIColor pickupTextColor] forState:UIControlStateNormal];
    [_laterButton setTitle:NSLocalizedString(@"new_booking_dialog_pickup_time_later", @"") forState:UIControlStateNormal];

    [_notesButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
    [_notesButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
    [_notesButton setTitle:NSLocalizedString(@"new_booking_dialog_notes", @"") forState:UIControlStateNormal];
    
    if (![CabOfficeSettings braintreeEnabled]) {
        self.paymentMethod = kPaymentMethodCash;
        _paymentCardButton.hidden = YES;
        _cardView.hidden = YES;
        _selectedCard = nil;
    } else {
        
        if ([CreditCardsManager getInstance].cards.count) {
            self.paymentMethod = kPaymentMethodCreditCard;
        } else {
            self.paymentMethod = kPaymentMethodCash;
            _paymentCardButton.enabled = NO;
            _cardView.hidden = YES;
        }
        _paymentCardButton.hidden = NO;
        
        [_cardButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
        [_cardButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
        _selectedCard = [CreditCardsManager getInstance].defaultCard;
        [_cardButton setTitle:_selectedCard.maskedNumber forState:UIControlStateNormal];
    }
    
    if ([CabOfficeSettings disableCashPaymentMethod]) {
        if (!_paymentCardButton.hidden) {
            _paymentCashButton.hidden = YES;
        }
    } else {
        _paymentCashButton.hidden = NO;
    }
    
    if (_paymentCardButton.hidden) {
        CGRect c = _paymentCardButton.frame;
        CGRect r = _paymentCashButton.frame;
        r.size.width = (c.origin.x + c.size.width) - r.origin.x;
        _paymentCashButton.frame = r;
    }
    
    if (_paymentCashButton.hidden) {
        CGRect c = _paymentCashButton.frame;
        CGRect r = _paymentCardButton.frame;
        r.size.width = (r.origin.x + r.size.width) - c.origin.x;
        r.origin.x = c.origin.x;
        _paymentCardButton.frame = r;
    }

    
    //vehicles
    _selectedVehicle = _vehiclesManager.defaultVehicle;
    if (_selectedVehicle) {
        [_vehicleButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
        [_vehicleButton setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
        [_vehicleButton setTitle:_selectedVehicle.name forState:UIControlStateNormal];
    } else {
        _vehicleView.hidden = YES;
    }

    _passengersLabel.font = [UIFont semiboldOpenSansOfSize:16];
    _passengersLabel.textColor = [UIColor grayColor];
    _passengersSlider.value = 1;
    
    _luggageLabel.font = [UIFont semiboldOpenSansOfSize:16];
    _luggageLabel.textColor = [UIColor grayColor];
    _luggageSlider.value = 0;

    NSInteger maxPassengers = 1;
    NSInteger maxLuggage = 0;
    for(Vehicle* v in _vehiclesManager.vehicles) {
        if (v.maxLuggage.integerValue > maxLuggage) {
            maxLuggage = v.maxLuggage.integerValue;
        }
        if (v.maxPassengers.integerValue > maxPassengers) {
            maxPassengers = v.maxPassengers.integerValue;
        }
    }
    _passengersSlider.maximumValue = maxPassengers;
    _luggageSlider.maximumValue = maxLuggage;

    
    [self setSliderValues];
    
    NSInteger minimumTimeOffset = [CabOfficeSettings minimumAllowedPickupTimeOffsetInMinutes];
    if (minimumTimeOffset) {
        self.selectedDate = self.selectedTime = [[NSDate date] dateByAddingMinimumAllowedPickupTimeOffsetInMinutes];
        _dateView.hidden = NO;
        _timeButton.hidden = NO;
        _nowButton.hidden = YES;
        _laterButton.hidden = YES;
    } else {
        _dateView.hidden = YES;
        _timeButton.hidden = YES;
        _nowButton.hidden = NO;
        _laterButton.hidden = NO;
        self.selectedDate = self.selectedTime = nil;
    }

    if (![CabOfficeSettings luggageSupportEnabled]) {
        _luggageView.hidden = YES;
    } else {
        _luggageView.hidden = NO;
    }
    
    if ([CabOfficeSettings minimumAllowedPickupTimeOffsetInMinutes]) {
        _pickupTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                        target:self
                                                      selector:@selector(pickupTimerFired:)
                                                      userInfo:nil
                                                       repeats:YES];
    }
    
    [self setButtonsTitles:_selectedTime day:_selectedDate];
    
    [self updateLayout];

    [super show];
    
    [self calculateFare];
    
}

- (void)pickupTimerFired:(NSTimer *)sender {
    _selectedTime = [_selectedTime dateByAddingTimeInterval:60];
    [self setButtonsTitles:_selectedTime day:_selectedDate];
}

- (void)stopPickupTimer {
    [_pickupTimer invalidate];
    _pickupTimer = nil;
}

- (void)dismiss {
    [self stopPickupTimer];
    [super dismiss];
}

- (void)setPaymentMethod:(NSString *)paymentMethod {
    _paymentMethod = paymentMethod;

    if ([_paymentMethod isEqualToString:kPaymentMethodCash]) {
        [_paymentCashButton setButtonBackgroundColor:[UIColor grayColor]];
        [_paymentCardButton setButtonBackgroundColor:[UIColor buttonColor]];
    } else {
        [_paymentCashButton setButtonBackgroundColor:[UIColor buttonColor]];
        [_paymentCardButton setButtonBackgroundColor:[UIColor grayColor]];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect r = _scrollView.frame;
    r.size.height = (_priceLabel.hidden ? _cancelButton.frame.origin.y : _priceLabel.frame.origin.y) - r.origin.y;
    _scrollView.frame = r;
}

- (void)updateRect:(UIView *)v y:(CGFloat)y {
    CGRect r = v.frame;
    r.origin.y = y;
    v.frame = r;
}

- (void)updateLayout
{
    CGFloat y = 0;
    
    [self updateRect:_paymentView y:y];
    y += _paymentView.frame.size.height;
    
    if (!_cardView.hidden) {
        [self updateRect:_cardView y:y];
        y += _cardView.frame.size.height;
    }
    
    [self updateRect:_timeView y:y];
    y += _timeView.frame.size.height;

    if (!_dateView.hidden) {
        [self updateRect:_dateView y:y];
        y += _dateView.frame.size.height;
    }

    [self updateRect:_passengersView y:y];
    y += _passengersView.frame.size.height;

    if (!_luggageView.hidden) {
        [self updateRect:_luggageView y:y];
        y += _luggageView.frame.size.height;
    }

    if (!_vehicleView.hidden) {
        [self updateRect:_vehicleView y:y];
        y += _vehicleView.frame.size.height;
    }

    if (!_notesView.hidden) {
        [self updateRect:_notesView y:y];
        y += _notesView.frame.size.height;
    }

    [self updateRect:_pickupView y:y];
    y += _pickupView.frame.size.height;
    
    if (!_dropoffView.hidden) {
        [self updateRect:_dropoffView y:y];
        y += _dropoffView.frame.size.height;
        _priceLabel.hidden = NO;
    } else {
        _priceLabel.hidden = YES;
    }

    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, y);
}

- (void)enableDateButton
{
    _dateView.hidden = NO;
    [self updateLayout];
}

- (NSDate *)pickupDate
{
    NSDate *date = nil;
    
    if (_selectedTime || _selectedDate)
    {
        NSDateComponents* sdc;
        if (_selectedDate)
            sdc = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:_selectedDate];
        else
            sdc = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
        
        NSDateComponents* stc;
        if (_selectedTime)
            stc = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:_selectedTime];
        else
            stc = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:[NSDate date]];
        
        date = [[NSCalendar currentCalendar] dateFromComponents:sdc];
        date = [[NSCalendar currentCalendar] dateByAddingComponents:stc toDate:date options:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit];
    }
    return date;
}

- (IBAction)bookButtonPressed:(id)sender
{
    [self showActivityView];
    
    NSInteger luggageCount = _luggageView.hidden ? -1 : _luggageSlider.value;
    CreditCard* card = [_paymentMethod isEqualToString:kPaymentMethodCreditCard] ? _selectedCard : nil;
    
    [self createBookingOn:[self pickupDate]
                     card:card
                  vehicle:_selectedVehicle
             luggageCount:luggageCount
          passengersCount:_passengersSlider.value
                     note:_notes];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    if (_confirmationBlock) {
        _confirmationBlock(nil, NO);
    }
    [self dismiss];
}

- (void)setButtonsTitles:(NSDate *)time day:(NSDate *)day
{
    [_timeButton setTitle:[time formatTimeUsingShortStyle:YES] forState:UIControlStateNormal];
    [_dateButton setTitle:[day formatDateUsingShortStyle:YES] forState:UIControlStateNormal];
}

- (BOOL)isDateToday:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) {
        return YES;
    }
    return NO;
}

- (IBAction)timeButtonPressed:(id)sender {

    NSDate* minimumDate = nil;

    if (_selectedDate)
    {
        if ([self isDateToday:_selectedDate])
        {
            minimumDate = [[NSDate date] dateByAddingMinimumAllowedPickupTimeOffsetInMinutes];
        }
    }
    else
    {
        minimumDate = [[NSDate date] dateByAddingMinimumAllowedPickupTimeOffsetInMinutes];
    }
    
    [DatePickerDialog showTimePicker:^(NSDate *date){
        [self stopPickupTimer];

        _dateView.hidden = NO;
        _timeButton.hidden = NO;
        _nowButton.hidden = YES;
        _laterButton.hidden = YES;
        [self updateLayout];

        self.selectedTime = date;
        if (!_selectedDate)
        {
            self.selectedDate = [NSDate date];
        }
        [self setButtonsTitles:date day:_selectedDate];
        [self calculateFare];
    } withMinimumDate:minimumDate];
}

- (IBAction)dateButtonPressed:(id)sender {

    [DatePickerDialog showDatePicker:^(NSDate *date){
        [self stopPickupTimer];

        self.selectedDate = date;
        if (!_selectedTime || [self isDateToday:_selectedDate])
        {
            self.selectedTime = [NSDate date];
        }
        [self setButtonsTitles:_selectedTime day:date];
        [self calculateFare];
    } ignoreMaxDaysAhead:NO];
}

- (void)setSliderValues {
    NSInteger maxPassengers = [_selectedVehicle.maxPassengers integerValue];
    _passengersSlider.minimumValue = 1;
    _passengersSlider.value = MIN(_passengersSlider.value, maxPassengers);

    [self passengersSliderValueChanged:_passengersSlider];
    
    NSInteger maxLuggageCount = [_selectedVehicle.maxLuggage integerValue];
    _luggageSlider.minimumValue = 0;
    _luggageSlider.value = MIN(_luggageSlider.value, maxLuggageCount);
    if (!maxLuggageCount) {
        _luggageView.hidden = YES;
    }
    [self luggageSliderValueChanged:_luggageSlider];
}

- (IBAction)vehicleButtonPressed:(id)sender {
    [VehicleSelectionDialog selectVehicleFromList:_vehiclesManager.vehicles
                                        maxLuggge:[NSNumber numberWithInt:_luggageSlider.value]
                                    maxPassengers:[NSNumber numberWithInt:_passengersSlider.value]
                               preselectedVehicle:_selectedVehicle
                                  completionBlock:^(Vehicle* vehicle) {
                                      [self setSelectedVehicle:vehicle];
    }];
}

- (IBAction)cardButtonPressed:(id)sender {
    [CardSelectionDialog selectCardFromList:[CreditCardsManager getInstance].cards
                            preselectedCard:_selectedCard
                            completionBlock:^(CreditCard* card) {
                                _selectedCard = card;
                                [_cardButton setTitle:card.maskedNumber forState:UIControlStateNormal];
                            }];
}

- (void)showActivityView {
    _activityView.hidden = NO;
    [_activityViewIndicator startAnimating];
}

- (void)hideActivityView {
    [_activityViewIndicator stopAnimating];
    _activityView.hidden = YES;
}

- (void)calculateFare {
    if (_pickup && _dropoff) {
        [self showActivityView];
        [[NetworkEngine getInstance] getTravelFare:_pickup.position
                                                to:_dropoff.position
                                          usingCar:_selectedVehicle.pk
                                     paymentMethod:_paymentMethod
                                    withPickupTime:[self pickupDate]
                                   completionBlock:^(NSObject *o) {
                                       [self hideActivityView];
                                       NSDictionary* d = (NSDictionary*)o;
                                       _priceLabel.text = d[@"fare"][@"formatted_total_cost"];
                                   }
                                      failureBlock:^(NSError *e) {
                                          [self hideActivityView];
                                            _priceLabel.text = @"";
                                      }];
    }
}

- (IBAction)nowButtonPressed:(id)sender {
    
}

- (IBAction)laterButtonPressed:(id)sender {
    [self timeButtonPressed:nil];
}

- (IBAction)notesButtonPressed:(id)sender {
    [NoteDialog showDialogWithText:_notes confirmationBlock:^(NSString *note) {
        if (note.length) {
            [_notesButton setTitle:note forState:UIControlStateNormal];
            _notes = note;
        }
    }];
}

- (void)selectMatchingCarForPassengers:(NSInteger)passengers andLuggage:(NSInteger)luggage {
    Vehicle* selected = _selectedVehicle;
    
    if (passengers <= selected.maxPassengers.integerValue && luggage <= selected.maxLuggage.integerValue) {
        //current car is ok
        return;
    }
    
    for(Vehicle* v in _vehiclesManager.vehicles) {
        if (v.maxLuggage.integerValue >= luggage && v.maxPassengers.integerValue >= passengers) {
            [self setSelectedVehicle:v];
            return;
        }
    }
}


- (IBAction)passengersSliderValueChanged:(id)sender {
    _passengersLabel.text = [NSString stringWithFormat:@"%d", (NSInteger)_passengersSlider.value];
    [self selectMatchingCarForPassengers:_passengersSlider.value andLuggage:_luggageSlider.value];
}

- (IBAction)luggageSliderValueChanged:(id)sender {
    _luggageLabel.text = [NSString stringWithFormat:@"%d", (NSInteger)_luggageSlider.value];
    [self selectMatchingCarForPassengers:_passengersSlider.value andLuggage:_luggageSlider.value];
}

- (IBAction)paymentCashButtonPressed:(id)sender {
    self.paymentMethod = kPaymentMethodCash;
    _cardView.hidden = YES;
    [self updateLayout];
    [self calculateFare];
}

- (IBAction)paymentCardButtonPressed:(id)sender {
    self.paymentMethod = kPaymentMethodCreditCard;
    _cardView.hidden = NO;
    [self updateLayout];
    [self calculateFare];
}

#pragma mark booking process
- (void)createBookingOn:(NSDate *)date
                   card:(CreditCard *)card
                vehicle:(Vehicle *)vehicle
           luggageCount:(NSInteger)luggageCount
        passengersCount:(NSInteger)passengersCount
                   note:(NSString *)note
{
    __block CreditCard* c = card;
    __block NSDate* pickupDate = date;
    
    [[NetworkEngine getInstance] createBooking:_pickup.title
                                 pickupZipCode:_pickup.zipCode
                                pickupLocation:_pickup.position
                                   dropoffName:_dropoff.title
                                dropoffZipCode:_dropoff.zipCode
                               dropoffLocation:_dropoff.position
                                    pickupDate:pickupDate
                                       carType:vehicle.pk
                                          card:card
                                  luggageCount:luggageCount
                               passengersCount:passengersCount
                                          note:note
                               completionBlock:^(NSObject *response) {
                                   
                                   if (c) {
                                       [self createTransactionForBooking:response card:c pickupDate:pickupDate];
                                   } else {
                                       if (_confirmationBlock) {
                                           _confirmationBlock(response, pickupDate != nil);
                                       }
                                       [self hideActivityView];
                                       [self dismiss];
                                   }
                               }
                                  failureBlock:^(NSError *error) {
                                      [self showBookingError:error];
                                  }];
}

- (void)showBookingError:(NSError *)error {
    [self hideActivityView];
    [MessageDialog showError:[NSString stringWithFormat:NSLocalizedString(@"new_booking_failed_body_fmt", @""), error.localizedDescription]
                   withTitle:NSLocalizedString(@"dialog_error_title", @"")];
}

- (void)createTransactionForBooking:(NSObject *)response card:(CreditCard *)card pickupDate:(NSDate *)pickupDate{
    __block NSMutableDictionary* booking = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)response];
    __block NSNumber *amount = booking[@"total_cost"][@"value"];
    [[BraintreeWrapperEngine getInstance] createTransaction:booking
                                                       card:card.token
                                                     amount:amount
                                            completionBlock:^(NSObject *response)
     {
         NSDictionary* transaction = (NSDictionary *)response;
         
         booking[@"payment_ref"] = transaction[@"id"];
         booking[@"status"] = @"incoming";
         booking[@"is_paid"] = @YES;
         booking[@"payment_method"] = kPaymentMethodCreditCard;
         booking[@"paid_value"] = amount;
         
         if (_confirmationBlock) {
             _confirmationBlock(booking, pickupDate != nil);
         }
         [self hideActivityView];
         [self dismiss];
     }
                                               failureBlock:^(NSError *error) {
                                                   [self showBookingError:error];
                                               }];
}

- (void)setSelectedVehicle:(Vehicle *)selectedVehicle {
    _selectedVehicle = selectedVehicle;

    [_vehicleButton setTitle:selectedVehicle.name forState:UIControlStateNormal];
    [self setSliderValues];
    [self updateLayout];
    [self calculateFare];
}

@end
