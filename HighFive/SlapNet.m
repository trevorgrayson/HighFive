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

@implementation SlapNet

NSString *domain = @"http://ipsumllc.com:8080";

+(InviteController*) sendInvite:(double) ferocity to:(User*) user
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    InviteController *controller = [[InviteController alloc] init];
    if([InviteController canSendText])
    {
        controller.body = [NSString stringWithFormat: @"HIGH FIVE! You just got hit with a %@ %4.2f slap. Slap me back: %@/invite/%@", [self highFiveDescription:ferocity], ferocity, domain, user.contact]; //ferocity, user.contact, user.name];
        controller.recipients = [NSArray arrayWithObjects: user.contact, nil];
        controller.messageComposeDelegate = controller;
        [topController presentViewController: controller animated:YES completion:nil];

        return controller;
    }
    return nil;
}

+(void) sendSlap:(double) ferocity to:(User*) user {
    [self sendNotification: ferocity to: user];
}

+ (void) receiveHighFive:(double) ferocity from:(User*) slapper
{
    Slap *slap = [Slap from: slapper with: ferocity];
    [Inbox addMessage: slap];
    //SlapAlert * alert = [SlapAlert newAlert: slap];
    //[alert show];
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

    NSString *uri = [NSString stringWithFormat: @"%@/slap/%@/%@/%4.2f", domain, fromContact, user.contact, ferocity];
    
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
                //UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"High Five!" message:@"Don't know who that is bro." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                //[confirm show];
            } else {
                NSString *message = [NSString stringWithFormat: @"Nice Five-skis bro."];
                UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Slap!" message: message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [confirm show];
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

+(void) registerUser:(NSString *) deviceToken identifiedBy:(NSString*) contact as:(NSString*) name {
    NSString *uri =[NSString stringWithFormat: @"%@/users/%@/%@", domain, contact, deviceToken];

    if( contact != nil) {
        uri = [NSString stringWithFormat: @"%@/users/%@/%@", domain, deviceToken, contact];
    }
    
    if( name != nil) {
        uri = [NSString stringWithFormat: @"%@/%@", uri, name];
    }

    NSLog(@"%@", uri);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: uri]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod: @"POST"];
    
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
                
//                ViewController *topController = (ViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
//                [topController waitingMode];
            }
            NSLog(@"Registered user %@, %@, %@", deviceToken, contact, name);
        }
    }];
}

+(UIViewController*) topController {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}
@end
