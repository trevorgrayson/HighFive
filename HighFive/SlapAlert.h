//
//  SlapAlert.h
//  HighFive
//
//  Created by Trevor Grayson on 9/29/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Slap.h"

@interface SlapAlert : UIAlertView

+(SlapAlert*) newAlert:(Slap*) slap;
@end
