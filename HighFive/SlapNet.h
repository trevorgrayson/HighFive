//
//  SlapNet.h
//  HighFive
//
//  Created by Trevor Grayson on 7/19/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "ViewController.h"
#import "AppDelegate.h"
#import "Slap.h"
#import "User.h"

@interface SlapNet : NSObject <UIAlertViewDelegate>//<MFMessageComposeViewControllerDelegate>

+(MFMessageComposeViewController*) sendInvite:(double) ferocity to:(User*) user;

+(MFMessageComposeViewController*) sendSlap:(double) ferocity to:(User*) user;

+ (void) receiveHighFive:(double) ferocity from:(User*) user;
@end
