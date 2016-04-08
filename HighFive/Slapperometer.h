//
//  Slapperometer.h
//  HighFive
//
//  Created by Trevor Grayson on 7/19/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface Slapperometer : NSObject

+ (BOOL) slapCheck:(CMAcceleration) accel;

@end
