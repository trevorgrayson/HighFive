//
//  MotionDelegate.m
//  HighFive
//
//  Created by Trevor Grayson on 1/8/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import "SlapMotionDelegate.h"

@implementation SlapMotionDelegate

double currentMaxAccelX;
double currentMaxAccelY;
double currentMaxAccelZ;

@synthesize targetRecipient;

- (id) init: (User*) recipient
{
    if (self = [super init])
    {
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.accelerometerUpdateInterval = .2;
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
            [self outputAccelertionData:accelerometerData.acceleration];
            
            if(error){ NSLog(@"%@", error); }
        }];
        
        //self.targetRecipient = recipient;
    }
    return self;
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    currentMaxAccelX = MAX(fabs(acceleration.x), currentMaxAccelX);
    currentMaxAccelY = MAX(fabs(acceleration.y), currentMaxAccelY);
    currentMaxAccelZ = MAX(fabs(acceleration.z), currentMaxAccelZ);
    
    if ( [Slapperometer slapCheck:acceleration] ) {
//        [self sendSlap];
        NSLog(@"Sending slap to %@!", targetRecipient);
        [SlapNet sendSlap: currentMaxAccelZ to: targetRecipient];
    }
}

-(void)reset {
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    currentMaxAccelZ = 0;
}

- (void)dealloc
{
    self.motionManager = nil;
    self.targetRecipient = nil;
}

@end
