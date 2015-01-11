//
//  SlapLocalNotification.m
//  HighFive
//
//  Created by Trevor Grayson on 1/10/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import "SlapLocalNotification.h"

@implementation SlapLocalNotification

+(void) newNotification:(Slap*) slap {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotification.alertBody = [NSString stringWithFormat:@"%@ slapped you", slap.slapper.name];
    localNotification.soundName = @"highfive-0.m4a";
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
