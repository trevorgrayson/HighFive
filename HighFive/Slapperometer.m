//
//  Slapperometer.m
//  HighFive
//
//  Created by Trevor Grayson on 7/19/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "Slapperometer.h"
#import "AppDelegate.h"

@implementation Slapperometer

BOOL midSlap;

+ (BOOL) slapCheck:(CMAcceleration) accel {
    if(fabs(accel.z) > 1.1f) {
        midSlap = YES;
    }
    
    if( midSlap && fabs(accel.z) < 1.0f) {
        midSlap = NO;
        return YES;
    }
    
    return NO;
}

@end
