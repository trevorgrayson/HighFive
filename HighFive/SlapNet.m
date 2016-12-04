//
//  SlapNet.m
//  HighFive
//
//  Created by Trevor Grayson on 7/19/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "SlapNet.h"
#import "SlapAlert.h"
#import "Inbox.h"
#import "AppDelegate.h"
#import "SlapWidget.h"
#import "HighFive-Swift.h"
#import "TableController.h"

@implementation SlapNet

+(InviteController*) sendInvite:(double) ferocity to:(User*) user
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    InviteController *controller = [[InviteController alloc] init];
    if([InviteController canSendText])
    {
        NSString *inviteUrl = [SlapRouter invite: user.contact];
        NSLog(@"%@", inviteUrl);
        controller.body = [NSString stringWithFormat: @"HIGH FIVE! You just got hit with a %@ %4.2f slap. Slap me back: %@", [self highFiveDescription:ferocity], ferocity, inviteUrl];
        controller.recipients = [NSArray arrayWithObjects: user.contact, nil];
        controller.messageComposeDelegate = controller;
        [topController presentViewController: controller animated:YES completion:nil];

        return controller;
    }
    return nil;
}

+(void) sendSlap:(double) ferocity to:(User*) user {
    [self.appDelegate playSlapSound];
    [self sendNotification: ferocity to: user];
}

+ (AppDelegate*) appDelegate {
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (void) receiveHighFive:(double) ferocity from:(User*) slapper
{
    NSLog(@"received HIGH FIVE ===============");
    Slap *slap = [Slap from: slapper with: ferocity];
    [Inbox addMessage: slap];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            break;
        default:
            break;
    }
}

double pendingFerocity = 0.0;
User *pendingUser;

+(void) sendNotification:(double) ferocity to:(User*) user {
    pendingFerocity = ferocity;
    pendingUser = user;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *fromContact = [prefs objectForKey:@"contact"];
    [prefs synchronize];

    NSString *uri = [NSString stringWithFormat: @"http://%@/slap/%@/%@/%4.2f", [SlapRouter domain], fromContact, user.contact, ferocity];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: uri]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler: ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        if (connectionError) {
            UIAlertView *alarm = [[UIAlertView alloc] initWithTitle:@"We left you hanging" message:@"Something prevented us from sending your request, please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alarm show];
            NSLog(@"%@", connectionError);
        } else { //TODO confirm 200 response.
            NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if([body isEqual: @"NOT_REGISTERED"]) {
                [SlapNet sendInvite: pendingFerocity to: pendingUser];
            } else {
                UIView *view = self.appDelegate.window.rootViewController.view.superview;
                SlapWidget * widget = [[SlapWidget alloc] initWithFrame: view.frame];
                widget.score.text = [NSString stringWithFormat:@"%0.2f", ferocity];
                [self.appDelegate.window.rootViewController.view.superview addSubview: widget];
            }
        }
    }];
}

+(NSString*) highFiveDescription:(double) m/*agnetude*/ {
    
    NSString *judgement = @"passable";
    
    if(m > 8)      { judgement = @"tremendous"; }
    else if(m > 7) { judgement = @"fierce";     }
    else if(m > 6) { judgement = @"braggable";  }
    else if(m > 5) { judgement = @"strong";     }
    else if(m > 4) { judgement = @"aggressive"; }
    else if(m > 3) { judgement = @"solid";      }
    else if(m > 2) { judgement = @"strong";     }
    
    return judgement;
}

+(void) registerUser:(NSString *) deviceToken identifiedBy:(NSString *)contact {
    [self registerUser:deviceToken identifiedBy: contact as:nil];
}

+(void) registerDefaultUser {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [prefs objectForKey: @"deviceToken"];
    NSString *contact     = [prefs objectForKey: @"contact"];
    NSString *name        = [prefs objectForKey: @"name"];
    
    if(name == nil)
        name = @"Anonymous";
    
    [SlapNet registerUser:deviceToken identifiedBy:contact as:name];
}

+(void) registerUser:(NSString *) deviceToken identifiedBy:(NSString*) contact as:(NSString*) name {
    NSLog(@"registering device deviceToken: %@ with contact: %@", deviceToken, contact);
    NSString *uri = [SlapRouter action:@"register"];
    uri = [uri stringByAppendingFormat: @"?invite=%@", contact];
    
    if ( deviceToken != nil ) { //REQUIRED
        uri = [uri stringByAppendingFormat: @"&deviceId=%@", deviceToken];
    }

    if ( name != nil ) {
        uri = [uri stringByAppendingFormat: @"&name=%@", name];
    }

    NSURL *url = [[NSURL alloc] initWithString:uri];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler: ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        if (connectionError) {
            UIAlertView *alarm = [[UIAlertView alloc] initWithTitle:@"We left you hanging" message:@"Something prevented us from registering you, please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alarm show];
            NSLog(@"%@", connectionError);
        } else { //TODO confirm 200 response.
            NSString *key = @"registered";
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSString *registered = [prefs objectForKey: key];

            if( registered == nil ) {
                UIAlertView *alarm = [[UIAlertView alloc] initWithTitle:@"You're in!" message:@"Welcome to the club, boss. Go get some." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alarm show];

                [prefs setObject: @"true" forKey:key];
                [prefs synchronize];
            }
            
            [self.appDelegate showMainController];
            
            NSLog(@"Registered user %@, %@, %@", deviceToken, contact, name);
        }
    }];
}

+(UIViewController*) topController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}

@end
