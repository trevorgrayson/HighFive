//
//  SlapLocalNotification.h
//  HighFive
//
//  Created by Trevor Grayson on 1/10/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Slap.h"

@interface SlapLocalNotification : UILocalNotification

+(void) newNotification:(Slap*) slap;

@end
