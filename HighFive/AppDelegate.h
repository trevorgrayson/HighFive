//
//  AppDelegate.h
//  HighFive
//
//  Created by Trevor Grayson on 7/18/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

#import "InviteWallController.h"
#import "RegisterController.h"
#import "SlapNet.h"
#import "User.h"

#import "AddressNameLookup.h"
#import "SlapLocalNotification.h"
#import "SlapAlert.h"
#import "Inbox.h"
#import "TableController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readwrite, nonatomic, assign) SystemSoundID slapSound;

@property (strong, nonatomic) UIViewController *invitationWall;

@property BOOL mainControllerPresent;

- (void) playSlapSound;

- (void) registerForNotifications;
- (void) showMainController;

- (void) setContact:(NSString*) newContact;

@end
