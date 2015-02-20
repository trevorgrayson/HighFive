//
//  User.m
//  HighFive
//
//  Created by Trevor Grayson on 8/1/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize name;
@synthesize contact;

- (id) init
{
    if (self = [super init])
    {
    }
    return self;
}

-(id) init:(NSString*) n with:(NSString*) c {
    self = [super init];
    if (self) {
        name = n;
        //format contact
        self.contact = c;
    }
    return self;
}

-(NSString*) initials {
    return [name substringToIndex:1];
}

+(User*) identifiedBy:(NSString*) contact {
    return [[User alloc] init: contact with:contact];
}

+(User*) named: (NSString*) name identifiedBy:(NSString*) contact {
    return [[User alloc] init: name with:contact];
}

- (void)dealloc
{
    name = nil;
    contact = nil;
}
@end
