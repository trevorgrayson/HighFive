//
//  User.m
//  HighFive
//
//  Created by Trevor Grayson on 8/1/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "User.h"

@implementation User

- (id) init
{
    if (self = [super init])
    {
    }
    return self;
}

-(id) init:(NSString*) name with:(NSString*) contact {
    self = [super init];
    if (self) {
        self.name = name;
        self.contact = contact;
    }
    return self;
}

@end
