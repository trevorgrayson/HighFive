//
//  Inbox.m
//  HighFive
//
//  Created by Trevor Grayson on 1/8/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import "Inbox.h"
#import "User.h"

@implementation Inbox
NSMutableArray *slaps;

+(void) addMessage:(Slap*) slap
{
    if( slaps == nil ) {
        NSLog(@"Intializing Inbox");
        slaps = [[NSMutableArray alloc] init];
    }
    
    [slaps addObject: slap];
}

+(NSInteger) count {
    return [[self messages] count];
}

+(Slap*) messageAtIndex:(NSInteger) index
{
    return [[self messages] objectAtIndex:index];
}

+(NSArray*) messages
{
    //Mocked
    return [ NSArray arrayWithObjects:
            [Slap from:
                [User identifiedBy:@"8603849769"]
                  with: 1.5],
            [Slap from:
                [User named:@"Paul" identifiedBy:@"8605559759"]
                  with: 1.9],
            nil];
}

//NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//NSString *deviceToken = [prefs objectForKey: @"deviceToken"];
//NSString *contact = [prefs objectForKey: @"contact"];

@end
