//
//  AppDelegate.h
//  HighFive
//
//  Created by Trevor Grayson on 7/18/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlapNet.h"
#import "ViewController.h"
#import "User.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property int notificationCount;

@property (readwrite, nonatomic, assign) SystemSoundID slapSound;

@property (strong, nonatomic) UIViewController *invitationWall;

- (void) playSlapSound;

@end