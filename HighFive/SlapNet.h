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
#import "InviteController.h"

@interface SlapNet : NSObject <UIAlertViewDelegate>

+(InviteController*) sendInvite:(double) ferocity to:(User*) user;

+(void) sendSlap:(double) ferocity to:(User*) user;

+(void) receiveHighFive:(double) ferocity from:(User*) user;

+(void) registerDefaultUser;
+(void) registerUser:(NSString *) deviceToken identifiedBy:(NSString *)contact;
+(void) registerUser:(NSString *) deviceToken identifiedBy:(NSString*) contact as:(NSString*) name;

+(NSString*) highFiveDescription:(double) m/*agnetude*/;
@end
