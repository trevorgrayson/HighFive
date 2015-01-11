//
//  MotionDelegate.h
//  HighFive
//
//  Created by Trevor Grayson on 1/8/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "User.h"
#import "Slapperometer.h"
#import "SlapNet.h"

@interface SlapMotionWorker : NSObject

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (strong, nonatomic) User *targetRecipient;

- (id) init: (User*) recipient;
- (void) harakiri;

@end
