//
//  Slapperometer.m
//  HighFive
//
//  Created by Trevor Grayson on 7/19/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "Slapperometer.h"

@implementation Slapperometer


+ (BOOL) slapCheck:(CMAcceleration) accel {
    return fabs(accel.z) > 1.1f;
}
@end
