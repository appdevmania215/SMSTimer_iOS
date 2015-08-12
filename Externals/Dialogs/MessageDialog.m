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

#import "MessageDialog.h"
#import "FlatTextField.h"

@interface MessageDialog() <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *header;
@property (weak, nonatomic) IBOutlet FlatButton *okButton;
@property (weak, nonatomic) IBOutlet FlatButton *yesButton;
@property (weak, nonatomic) IBOutlet FlatButton *noButton;
@property (weak, nonatomic) IBOutlet UILabel *textView;
@property (weak, nonatomic) IBOutlet FlatTextField *optionalTextField;

@property (strong, nonatomic) NSString* dialogMessage;
@property (strong, nonatomic) NSString* dialogTitle;
@property (copy, nonatomic) MessageDialogConfirmationBlock confirmationBlock;
@property (assign, nonatomic) BOOL confirmationDialog;
@property (assign, nonatomic) BOOL confirmationDialogWithText;

- (IBAction)okButtonPressed:(id)sender;
- (IBAction)yesButtonPressed:(id)sender;
- (IBAction)noButtonPressed:(id)sender;

@end

@implementation MessageDialog

- (id)initWithTitle:(NSString *)title andMessage:(NSString *)message;
{
    self = [super initWithNibName:@"MessageDialog"];
    if (self) {
        self.dialogMessage = message;
        self.dialogTitle = title;
        self.confirmationDialog = NO;
        self.confirmationDialogWithText = NO;
    }
    return self;
}

+ (MessageDialog*) showMessage:(NSString *)message
                     withTitle:(NSString *)title
{
    MessageDialog* dialog = [[MessageDialog alloc] initWithTitle:title
                                                      andMessage:message];
    dialog.header.backgroundColor = [UIColor dialogOkBackgroundColor];
    dialog.confirmationDialog = NO;
    [dialog show];
    return dialog;
}

+ (MessageDialog*) showError:(NSString *)message
                   withTitle:(NSString *)title
{
    MessageDialog* dialog = [[MessageDialog alloc] initWithTitle:title
                                                      andMessage:message];
    dialog.header.backgroundColor = [UIColor dialogErrorBackgroundColor];
    [dialog show];
    return dialog;
}

+ (MessageDialog*) askConfirmation:(NSString *)message
                         withTitle:(NSString *)title
                 confirmationBlock:(MessageDialogConfirmationBlock)confirmationBlock
{
    MessageDialog* dialog = [[MessageDialog alloc] initWithTitle:title
                                                      andMessage:message];
    dialog.header.backgroundColor = [UIColor dialogConfirmBackgroundColor];
    dialog.confirmationDialog = YES;
    dialog.confirmationBlock = confirmationBlock;
    [dialog show];
    return dialog;
}

+ (MessageDialog*) askConfirmationWithReason:(NSString *)message
                                   withTitle:(NSString *)title
                           confirmationBlock:(MessageDialogConfirmationBlock)confirmationBlock
{
    MessageDialog* dialog = [[MessageDialog alloc] initWithTitle:title
                                                      andMessage:message];
    dialog.header.backgroundColor = [UIColor dialogErrorBackgroundColor];
    dialog.confirmationDialogWithText = YES;
    dialog.confirmationBlock = confirmationBlock;
    [dialog show];
    return dialog;
}

- (void)show
{
    if (_confirmationDialogWithText)
    {
        _confirmationDialog = YES;
    }
    
    UIFont *font = [UIFont lightOpenSansOfSize:17];
    
    self.contentView.backgroundColor = [UIColor dialogDefaultBackgroundColor];
    
    [_textView setTextColor:[UIColor dialogDefaultForegroundColor]];
    [_textView setFont:font];
    [_textView setBackgroundColor:[UIColor clearColor]];
    [_textView setText:_dialogMessage];
    [_textView setLineBreakMode:NSLineBreakByWordWrapping];
    [_textView setNumberOfLines:0];
    
    CGSize maxSize = CGSizeMake(_textView.frame.size.width, CGFLOAT_MAX);
    CGSize requiredSize = [_textView sizeThatFits:maxSize];
    
    NSInteger height = requiredSize.height;
    
    CGRect frame = _textView.frame;
    frame.size.height = height;
    frame.origin.y += 10;
    _textView.frame = frame;

    frame = self.contentView.frame;
    frame.size.height = height + 60 + 60 + 20;

    if (_confirmationDialogWithText)
    {
        CGRect r = _optionalTextField.frame;
        frame.size.height += r.size.height + 10;
        r.origin.y = _textView.frame.origin.y + _textView.frame.size.height + 10;
        _optionalTextField.frame = r;
        
        _optionalTextField.placeholder = NSLocalizedString(@"booking_cancel_reason_hint", @"");
        _optionalTextField.font = font;
    }
    else
    {
        _optionalTextField.hidden = YES;
    }
    
    self.contentView.frame = frame;
    
    [_header setTitle:_dialogTitle forState:UIControlStateNormal];
    [_header setTitleColor:[UIColor dialogDefaultForegroundColor] forState:UIControlStateNormal];
    [_header.titleLabel setFont:[UIFont lightOpenSansOfSize:20]];

    frame = _okButton.frame;
    frame.origin.y = self.contentView.frame.size.height - _okButton.frame.size.height;
    _okButton.frame = frame;
    [_okButton setTitleFont:[UIFont lightOpenSansOfSize:20]];
    [_okButton setTitle:NSLocalizedString(@"dialog_button_ok", @"") forState:UIControlStateNormal];

    frame = _noButton.frame;
    frame.origin.y = self.contentView.frame.size.height - _noButton.frame.size.height;
    _noButton.frame = frame;
    [_noButton setTitleFont:[UIFont lightOpenSansOfSize:20]];
    [_noButton setTitle:NSLocalizedString(@"dialog_button_no", @"") forState:UIControlStateNormal];

    frame = _yesButton.frame;
    frame.origin.y = self.contentView.frame.size.height - _yesButton.frame.size.height;
    _yesButton.frame = frame;
    [_yesButton setTitleFont:[UIFont lightOpenSansOfSize:20]];
    [_yesButton setTitle:NSLocalizedString(@"dialog_button_yes", @"") forState:UIControlStateNormal];

    if (_confirmationDialog)
    {
        _yesButton.hidden = NO;
        _noButton.hidden = NO;
        _okButton.hidden = YES;
    }
    else
    {
        _yesButton.hidden = YES;
        _noButton.hidden = YES;
        _okButton.hidden = NO;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(tapGesture:)];
    tap.delegate = self;
    tap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tap];

    [super show];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)tapGesture:(UITapGestureRecognizer*)gesture
{
    [_optionalTextField resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (IS_IPAD) {
        CGRect aRect = self.contentView.frame;
        aRect.origin.y -= 100;
        self.contentView.frame = aRect;
    } else {
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        CGRect aRect = self.contentView.frame;
        
        CGFloat ep = aRect.origin.y + aRect.size.height;
        CGFloat ke = self.frame.size.height - kbSize.height;
        
        if (ke < ep)
        {
            aRect.origin.y = aRect.origin.y - (ep - ke);
            self.contentView.frame = aRect;
        }
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (IS_IPAD) {
        CGRect aRect = self.contentView.frame;
        aRect.origin.y += 100;
        self.contentView.frame = aRect;
    } else {
        self.contentView.center = self.center;
    }
}

- (void)dismiss
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [super dismiss];
}

- (IBAction)okButtonPressed:(id)sender
{
    [self dismiss];
}

- (IBAction)noButtonPressed:(id)sender
{
    [self dismiss];
}

- (IBAction)yesButtonPressed:(id)sender
{
    if (_confirmationBlock) {
        _confirmationBlock(_optionalTextField.text);
    }
    [self dismiss];
}

@end
