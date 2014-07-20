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

-(void) incomingSlap {
    
}
@end
