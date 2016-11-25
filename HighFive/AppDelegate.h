//
//  AppDelegate.h
//  HighFive
//
//  Created by Trevor Grayson on 7/18/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InviteWallController.h"
#import "RegisterController.h"
#import "ViewController.h"
#import "SlapNet.h"
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readwrite, nonatomic, assign) SystemSoundID slapSound;

@property (strong, nonatomic) UIViewController *invitationWall;

- (void) playSlapSound;

- (void) registerForNotifications;

@end
