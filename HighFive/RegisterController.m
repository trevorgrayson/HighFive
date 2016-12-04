//
//  RegisterController.m
//  HighFive
//
//  Created by Trevor Grayson on 11/5/16.
//  Copyright © 2016 Ipsum LLC. All rights reserved.
//

#import "RegisterController.h"


@interface RegisterController ()

@end

@implementation RegisterController

SlapMotionWorker *slapWorker;

float originalOffset = 0;
int kOFFSET_FOR_KEYBOARD = 100;

NSString* STATE_RAISE_PHONE = @"Raise you phone";
NSString* STATE_REGISTER = @"Register or Sign Up";
NSString* STATE_SLAP_PHONE = @"Slap your phone to sign in!";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.mobileField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self
                                        action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    originalOffset = self.view.frame.origin.y;
}

-(void)textFieldDidChange: (NSObject*) obj {
    if( [self.mobileField.text length] >= 10 ) {
        self.commandText.text = STATE_RAISE_PHONE;
        [self setViewMovedUp: NO];
        [self dismissKeyboard];
        
        AppDelegate *deleg = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [deleg setContact: self.mobileField.text];
        
        //Ask for deviceToken access
        [self requestNotification];
        
        //TODO and hook from return answer
        NSString *deviceToken = @"";
        
        // save number
        ReachUp *reachUp = [[ReachUp alloc] init];
        [reachUp registerActionOnReachUp:^(void) {
            self.commandText.text = STATE_SLAP_PHONE;
            
            User *user = [[User alloc] init];
            user.contact = [self getContactFromForm];
            slapWorker = [[SlapMotionWorker alloc] init: user];
            slapWorker.deviceToken = deviceToken;

        }];
    } else {
        self.commandText.text = STATE_REGISTER;
    }
}

-(BOOL)textFieldShouldBeginEditing:(NSObject*) obj {
    [self setViewMovedUp: YES];
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(NSObject*) obj {
    [self setViewMovedUp: NO];
    return YES;
}

-(void) requestNotification {
    //UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    //TODO older versions?
    if(! [[UIApplication sharedApplication] isRegisteredForRemoteNotifications] ) {
        AppDelegate *del = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        //TODO I O U
        [del registerForNotifications];
    }
}

-(void)setViewMovedUp:(BOOL) movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    NSLog(@"%f %f", rect.origin.y, originalOffset);
    if (movedUp) {
        if( rect.origin.y == originalOffset ) {
            rect.origin.y -= kOFFSET_FOR_KEYBOARD;
            rect.size.height += kOFFSET_FOR_KEYBOARD;
        }
    } else {
        if( rect.origin.y == originalOffset - kOFFSET_FOR_KEYBOARD) {
            rect.origin.y += kOFFSET_FOR_KEYBOARD;
            rect.size.height -= kOFFSET_FOR_KEYBOARD;
        }
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

-(NSString*) getContactFromForm {
    return self.mobileField.text;
}

-(void)dismissKeyboard {
    [self.mobileField resignFirstResponder];
    [self setViewMovedUp:NO];
}

//TODO: need to check before trying to register bug
@end
