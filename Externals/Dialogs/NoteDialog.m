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

#import "NoteDialog.h"
#import "UITextViewWithPlaceholder.h"

@interface NoteDialog()

@property (weak, nonatomic) IBOutlet UIButton *header;
@property (weak, nonatomic) IBOutlet FlatButton *okButton;
@property (weak, nonatomic) IBOutlet FlatButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextViewWithPlaceholder *textView;

- (IBAction)okButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@property (nonatomic, copy) NoteDialogConfirmationBlock confirmationBlock;
@property (nonatomic, strong) NSString* text;

@end

@implementation NoteDialog

- (id)init
{
    self = [super initWithNibName:@"NoteDialog"];
    if (self) {
    }
    return self;
}

+ (NoteDialog*) showDialogWithText:(NSString *)text confirmationBlock:(NoteDialogConfirmationBlock)confirmationBlock

{
    NoteDialog* dialog = [[NoteDialog alloc] init];
    
    if (confirmationBlock) {
        dialog.confirmationBlock = confirmationBlock;
    }

    dialog.text = text;
    dialog.dimmBackground = NO;
    
    if (!IS_IPAD) {
        dialog.fullscreen = YES;
    }

    [dialog show];
    return dialog;
}

- (void)show
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    self.contentView.backgroundColor = [UIColor dialogDefaultBackgroundColor];

    if (_text) {
        _textView.text = _text;
    }
    _textView.placeholder = NSLocalizedString(@"editor_message_hint", @"");
    _textView.font = [UIFont lightOpenSansOfSize:15];
    
    [_header setTitle:NSLocalizedString(@"new_booking_dialog_notes_editor_title", @"") forState:UIControlStateNormal];
    [_header.titleLabel setFont:[UIFont lightOpenSansOfSize:19]];
    [_header setTitleColor:[UIColor buttonTextColor] forState:UIControlStateNormal];
    [_header setBackgroundColor:[UIColor buttonColor]];

    [_cancelButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
    [_cancelButton setTitle:NSLocalizedString(@"editor_button_cancel", @"") forState:UIControlStateNormal];
    
    [_okButton setTitleFont:[UIFont lightOpenSansOfSize:19]];
    [_okButton setTitle:NSLocalizedString(@"editor_button_ok", @"") forState:UIControlStateNormal];
    
    [_textView becomeFirstResponder];
    
    [super show];
}

- (void)dismiss
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [super dismiss];
}

- (IBAction)okButtonPressed:(id)sender
{
    if (_confirmationBlock) {
        _confirmationBlock(_textView.text);
    }
    [self dismiss];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    if (_confirmationBlock) {
        _confirmationBlock(nil);
    }
    [self dismiss];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    CGRect frame = _okButton.frame;
    CGFloat y = self.contentView.frame.size.height - kbSize.height - 1;
    frame.origin.y = y - _okButton.frame.size.height;
    _okButton.frame = frame;
    
    frame = _cancelButton.frame;
    frame.origin.y = y - _cancelButton.frame.size.height;
    _cancelButton.frame = frame;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
}

@end
