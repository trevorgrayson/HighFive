//
//  ReachUp.m
//  HighFive
//
//  Created by Trevor Grayson on 11/25/16.
//  Copyright © 2016 Ipsum LLC. All rights reserved.
//

#import "ReachUp.h"

const double kUPDATE_INTERVAL = 0.2f;
// instantiate new ReachUp with method of form submit
// form submit
// 201/200 => past signup garden

@implementation ReachUp

double distanceTraveledX = 1;
double distanceTraveledY = 1;
double distanceTraveledZ = 1;

double THRESHOLD_DIST = 10;

void (^completion)(void);

- (id) init
{
    if (self = [super init])
    {
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = kUPDATE_INTERVAL;
        
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *deviceMotion, NSError *error) {
            if(error){
                NSLog(@"%@", error);
            } else {
                [self outputAccelertionData:deviceMotion.userAcceleration];
            }
        }];
        
    }
    return self;
}

- (void) registerActionOnReachUp:(void(^)()) action {
    completion = action;
}

-(BOOL) didTrigger {
    return distanceTraveledY > THRESHOLD_DIST ||
        distanceTraveledZ < -THRESHOLD_DIST;
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    distanceTraveledX += fmax(0, acceleration.x / kUPDATE_INTERVAL);
    distanceTraveledY += fmax(0, acceleration.y / kUPDATE_INTERVAL);
    distanceTraveledZ += fmax(0, acceleration.z / kUPDATE_INTERVAL);
    
//    NSLog(@"DISTANCE x: %f, y: %f, z: %f", acceleration.x, acceleration.y, acceleration.z);
//    NSLog(@"DISTANCE x: %f, y: %f, z: %f", distanceTraveledX, distanceTraveledY, distanceTraveledZ);
    
    if([self didTrigger]) {
        [completion invoke];
        [self harakiri];
    }
    
}

//TODO if y > z == HIGH FIVE else LOW FIVE

-(void)reset {
    distanceTraveledX = 0;
    distanceTraveledY = 0;
    distanceTraveledZ = 0;
}

- (void) harakiri {
    [self.motionManager stopMagnetometerUpdates];
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopDeviceMotionUpdates ];
    [self.motionManager stopGyroUpdates];
    self.motionManager.accelerometerUpdateInterval = 1000000;
    
    //self.motionManager = nil;
}

- (void)dealloc
{
    self.motionManager = nil;
}

@end
