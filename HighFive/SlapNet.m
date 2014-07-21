//
//  SlapNet.m
//  HighFive
//
//  Created by Trevor Grayson on 7/19/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "SlapNet.h"

@implementation SlapNet

- (void) sendInvite:(double) ferocity to:(NSString*) contact
{
    
//    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
//        controller.body = [NSString stringWithFormat: @"HIGH FIVE! You just got hit with a %@ %4.2f slap. Slap me back", [self highFiveDescription:ferocity], ferocity];
//        controller.recipients = [NSArray arrayWithObjects: contact, nil];
//        controller.messageComposeDelegate = self;
//        
//        [self presentViewController:controller animated:YES completion:nil];
//        [self reset:nil];
    }
}

-(void) sendSlap:(double) ferocity to:(NSString*) contact {
    [self sendInvite: ferocity to: contact];
}

- (void) receiveHighFive:(double) ferocity from:(NSString*) contact
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

-(NSString*) highFiveDescription:(double) m/*agnetude*/ {
    
    NSString *judgement = @"passable";
    
    if(m > 8) {
        judgement = @"tremendous";
    } else if(m > 7) {
        judgement = @"fierce";
    } else if(m > 6) {
        judgement = @"braggable";
    } else if(m > 5) {
        judgement = @"strong";
    } else if(m > 4) {
        judgement = @"aggressive";
    } else if(m > 3) {
        judgement = @"strong";
    } else if(m > 2) {
        judgement = @"solid";
    }
    
    return judgement;
}

@end
