//
//  SlapNet.m
//  HighFive
//
//  Created by Trevor Grayson on 7/19/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "SlapNet.h"

@implementation SlapNet

+(MFMessageComposeViewController*) sendInvite:(double) ferocity to:(User*) user
{
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = [NSString stringWithFormat: @"HIGH FIVE! You just got hit with a %@ %4.2f slap. Slap me back: hi5://?%4.2f&%@&%@", [self highFiveDescription:ferocity], ferocity, ferocity, user.contact, user.name];
        controller.recipients = [NSArray arrayWithObjects: user.contact, nil];
        //controller.messageComposeDelegate = self;
        //[self presentViewController:controller animated:YES completion:nil];

        return controller;
    }
    return nil;
}

+(MFMessageComposeViewController*) sendSlap:(double) ferocity to:(User*) user {

    [self sendNotification: ferocity to: user];
    return [self sendInvite: ferocity to: user];
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

+(void) sendNotification:(double) ferocity to:(User*) user {
    NSString *uri = [NSString stringWithFormat: @"http://ipsumllc.com/hi5/?jerk=%4.2f&to=%@&from=%@&name=%@", ferocity, user.contact, @"+18603849759", user.name];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: uri]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler: ^(NSURLResponse* response, NSData* data, NSError* connectionError) {
        if (connectionError) {
            UIAlertView *alarm = [[UIAlertView alloc] initWithTitle:@"We left you hanging" message:@"Something prevented us from sending your request, please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alarm show];
        } else { //TODO confirm 200 response.
            UIAlertView *confirm = [[UIAlertView alloc] initWithTitle:@"High Five!" message:@"Slap! Nice Five-skis bro." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [confirm show];
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

@end
