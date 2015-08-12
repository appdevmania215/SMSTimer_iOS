//
//  RecepientTagView.m
//  TextTimer
//
//  Created by admin on 6/19/14.
//  Copyright (c) 2014 abma. All rights reserved.
//

#import "RecepientTagView.h"
#import "Constants.h"
#import "RecepientsContainerView.h"

@implementation RecepientTagView

@synthesize mContact;
@synthesize mSize;
@synthesize mParentView;

static CGFloat recepientPadding = 2;
static CGFloat linespace = 1;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (void) awakeFromNib{
    [super awakeFromNib];
    [self setup];
}

-(void) setup {
    mSize = CGSizeMake(0, 0);
    self.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    [self setupAction];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    
//}
- (CGSize) getSize {
    return mSize;
}
- (CGSize) setContact:(Contact*)contact {
    if ( contact == mContact )
        return mSize;
    mContact = contact;
    if ( mContact ) {
        UIFont *namefont = [UIFont systemFontOfSize:kRecepientNameTextFontSize];
        NSDictionary *nameAttributes = [NSDictionary dictionaryWithObjectsAndKeys:namefont, NSFontAttributeName, nil];
        CGSize stringSize = [[mContact getContactName] sizeWithAttributes:nameAttributes];
        CGFloat x = recepientPadding;
        CGFloat y = recepientPadding;
        
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(x, y, stringSize.width, stringSize.height)];
        lblName.text = [mContact getContactName];
        [lblName setFont:namefont];
        [self addSubview:lblName];
        
        CGFloat width = stringSize.width;
        CGFloat height = y + stringSize.height;
        
        y = height;
        
        NSDictionary *phoneNumbers = [mContact getPhoneList];
        NSArray *keys = [phoneNumbers allKeys];
        for ( int i = 0; i < [keys count]; i++ ) {
            NSString *key = keys[i];
            NSString *value = [phoneNumbers valueForKey:key];
            NSString *phoneNumber = [NSString stringWithFormat:@"%@:%@", key, value];
            
            UIFont *phoneNumberFont = [UIFont systemFontOfSize:kRecepientPhoneNumberTextFontSize];
            NSDictionary *phoneNumberAttributes = [NSDictionary dictionaryWithObjectsAndKeys:phoneNumberFont, NSFontAttributeName, nil];
            CGSize size = [phoneNumber sizeWithAttributes:phoneNumberAttributes];
            
            y += linespace;
            
            UILabel *lblPhoneNumber = [[UILabel alloc] initWithFrame:CGRectMake(x, y, size.width, size.height)];
            lblPhoneNumber.text = phoneNumber;
            [lblPhoneNumber setFont:phoneNumberFont];
            [self addSubview:lblPhoneNumber];
            
            if ( width < size.width )
                width = size.width;
            height = y + size.height;
            y = height;
        }
        height += recepientPadding;
        width += 2 * recepientPadding;
        
        mSize = CGSizeMake(width, height);
    }
    else {
        mSize = CGSizeMake(0, 0);
    }
    return mSize;
}

#pragma mark - Touch Event
-(void)setupAction {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
}

-(void)handleTap:(UITapGestureRecognizer *)recognizer {
    if ( [mParentView isEditable] == YES ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Recepient" message:@"Are you sure to delete this recepient?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            [mParentView deleteRecepient:self];
            break;
            
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ( [mParentView isEditable] == YES ) {
        UITouch *touch = [touches anyObject];
        if ( touch.view == self ) {
            self.layer.opacity = 0.5;
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ( touch.view == self ) {
        self.layer.opacity = 1;
    }
}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if ( touch.view == self ) {
        self.layer.opacity = 1;
    }
}


@end
