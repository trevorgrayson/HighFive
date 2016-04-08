//
//  InviteDelegate.m
//  HighFive
//
//  Created by Trevor Grayson on 9/6/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "InviteController.h"

@implementation InviteController

//SMS MESSAGE Compose
-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
