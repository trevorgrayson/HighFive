//
//  Slap.h
//  HighFive
//
//  Created by Trevor Grayson on 7/20/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Slap : NSObject

//TODO how are you destroying?
@property (strong, nonatomic) User *slapper;
@property double ferocity;

-(id) init:(User*) user with:(float) f;

+(Slap*) from:(User*) from with:(float) f;

@end
