//
//  MotionDelegate.m
//  HighFive
//
//  Created by Trevor Grayson on 1/8/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import "SlapMotionWorker.h"

@implementation SlapMotionWorker

@synthesize targetRecipient;
@synthesize deviceToken;

@synthesize currentMaxAccelX;
@synthesize currentMaxAccelY;
@synthesize currentMaxAccelZ;

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
        
        self.targetRecipient = recipient;
    }
    return self;
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    currentMaxAccelX = MAX(fabs(acceleration.x), currentMaxAccelX);
    currentMaxAccelY = MAX(fabs(acceleration.y), currentMaxAccelY);
    currentMaxAccelZ = MAX(fabs(acceleration.z), currentMaxAccelZ);
    
    NSString *mode;
    //Mode should not change if value is much > 1 (gravity)
    if (acceleration.y < acceleration.z) {
        mode = @"High Five";
    } else {
        mode = @"Low Five";
    }
    
    if ( [Slapperometer slapCheck: acceleration] ) {
        
        if( deviceToken != nil ) {
            [SlapNet registerUser: deviceToken identifiedBy: targetRecipient.contact];
        } else {
            NSLog(@"Sending slap to %@!", targetRecipient);
                
            [SlapNet sendSlap: currentMaxAccelZ to: targetRecipient];
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName: @"harakiri" object: self];
        }
        
        [self harakiri];

    }
}

//TODO if y > z == HIGH FIVE else LOW FIVE

-(void)reset {
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    currentMaxAccelZ = 0;
}

- (void) harakiri {
    [self.motionManager stopMagnetometerUpdates];
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopDeviceMotionUpdates ];
    [self.motionManager stopGyroUpdates];
    
    self.motionManager = nil;
    self.targetRecipient = nil;
}

- (void)dealloc
{
    self.motionManager = nil;
    self.targetRecipient = nil;
    self.deviceToken = nil;
}

@end
