//
//  ContactUsViewController.m
//  TextTimer
//
//  Created by admin on 6/17/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "ContactUsViewController.h"
#import "DemoTextField.h"
#import "DemoTextView.h"
#import "CustomButton.h"

#import "Constants.h"

@interface ContactUsViewController ()

@end

@implementation ContactUsViewController

@synthesize tfSubject;
@synthesize tfReplyEmail;
@synthesize tvMessage;
@synthesize scrollView;
@synthesize btnSend;

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
    [tfReplyEmail setEmailField:YES];
    
    scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 360.0f);
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, 360.0f, 0);
    scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 360.0f, 0);
    
    [btnSend setCorner:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [tfSubject layoutSublayersOfLayer:tfSubject.layer];
    [tfReplyEmail layoutSublayersOfLayer:tfReplyEmail.layer];
    [tvMessage layoutSublayersOfLayer:tvMessage.layer];
}

#pragma mark - Button Action

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)sendEmail:(id)sender {
    if ( [tfSubject validate] == YES &&
        [tfReplyEmail validate] == YES &&
        [tvMessage validate] == YES) {
        if ( [MFMailComposeViewController canSendMail] ) {
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            
            mc.mailComposeDelegate = self;
            [mc setSubject:tfSubject.text];
            [mc setMessageBody:[NSString stringWithFormat:@"%@ \n\nPlease reply to %@",  tvMessage.text, tfReplyEmail.text] isHTML:NO];
            [mc setToRecipients:[NSArray arrayWithObjects:ContactEmailAddress, nil]];
            [mc setTitle:@"Text Timer"];
            [mc.navigationBar setTintColor:[UIColor whiteColor]];
            mc.title = @"Text Timer";
            
            // Present mail view controller on screen
            [self presentViewController:mc animated:YES completion:nil];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                            message:@"Your device doesn't support the composer sheet"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

#pragma mark - MFMailCompose ViewController Delegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
