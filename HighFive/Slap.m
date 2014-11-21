//
//  Slap.m
//  HighFive
//
//  Created by Trevor Grayson on 7/20/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "Slap.h"

@implementation Slap
@synthesize slapper;
@synthesize ferocity;

- (id) init
{
    if (self = [super init])
    {
    }
    return self;
}

-(id) init:(User*) user with:(float) f {
    self = [super init];
    if (self) {
        slapper = user;
        ferocity = f;
    }
    return self;
}

+(Slap*) from:(User*) from with:(float) f {
    return [[Slap alloc] init:from with:f];
}

@end
