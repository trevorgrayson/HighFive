//
//  ReachUp.h
//  HighFive
//
//  Created by Trevor Grayson on 11/25/16.
//  Copyright © 2016 Ipsum LLC. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>


@interface ReachUp : NSObject 

@property (strong, nonatomic) CMMotionManager *motionManager;

- (void) registerActionOnReachUp:(void(^)()) action;

@end
