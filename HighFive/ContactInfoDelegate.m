//
//  ContactInfoDelegate.m
//  HighFive
//
//  Created by Trevor Grayson on 9/10/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "ContactInfoDelegate.h"

@implementation ContactInfoDelegate

NSString *key = @"contact";

+(ContactInfoDelegate*) checkForContactInfo {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *contact = [prefs objectForKey: key];
    
    if (contact == nil) {
        ContactInfoDelegate *alert = [[ContactInfoDelegate alloc] initWithTitle:@"Hello" message:@"To get started, please enter the phone number for this device" delegate: nil cancelButtonTitle:@"I'm out" otherButtonTitles:@"Done", nil];
        [alert setAlertViewStyle: UIAlertViewStylePlainTextInput];
        [alert setDelegate: alert];
        UITextField * textField = [alert textFieldAtIndex:0];
        [textField setKeyboardType: UIKeyboardTypeNumberPad];
        return alert;
    } else {
        return nil;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    UITextField *textField = [alertView textFieldAtIndex:0];
    
    switch (buttonIndex) {
        case 1:
            NSLog(@"SETTING CONTACT %@", textField.text);
            [self setContact: textField.text];
            break;
            
        default:
            break;
    }
}

- (void) setContact:(NSString*) contact {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: contact forKey: key];
    [prefs synchronize];
}

@end
