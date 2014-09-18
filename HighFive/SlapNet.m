//
//  SlapNet.m
//  HighFive
//
//  Created by Trevor Grayson on 7/19/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "SlapNet.h"

@implementation SlapNet

NSString *domain = @"http://ipsumllc.com:8080";

+(InviteController*) sendInvite:(double) ferocity to:(User*) user
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    InviteController *controller = [[InviteController alloc] init];
    if([InviteController canSendText])
    {
        controller.body = [NSString stringWithFormat: @"HIGH FIVE! You just got hit with a %@ %4.2f slap. Slap me back: %@/invite", [self highFiveDescription:ferocity], ferocity, domain]; //ferocity, user.contact, user.name];
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

+ (void) receiveHighFive:(double) ferocity from:(User*) user
{
    NSString *msg = [NSString stringWithFormat: @"HIGH FIVE! You just got hit with a %@ %4.2f slap. Would you like to slap them back?", [self highFiveDescription:ferocity], ferocity];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SLAP!" message: msg delegate:nil cancelButtonTitle:@"Nope!" otherButtonTitles: @"Slap Back", nil];
    [alert show];
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
                UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"Slap!" message:@"Nice Five-skis bro." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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
    else if(m > 3) { judgement = @"strong";     }
    else if(m > 2) { judgement = @"solid";      }
    
    return judgement;
}

+(void) registerUser:(NSString *) deviceToken identifiedBy:(NSString *)contact {
    [self registerUser:deviceToken identifiedBy: contact as:nil];
}

+(void) registerUser:(NSString *) deviceToken identifiedBy:(NSString*) contact as:(NSString*) name {
    NSString *uri =[NSString stringWithFormat: @"%@/users/%@/%@", domain, contact, deviceToken];

    if( contact != nil) {
        uri = [NSString stringWithFormat: @"%@/users/%@/%@/%@", domain, contact, name, deviceToken];
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
            NSLog(@"Registered user %@, %@, %@", deviceToken, contact, name);
        }
    }];
}

@end
