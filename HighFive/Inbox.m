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
NSMutableArray *_slaps;

+(NSMutableArray*) slaps {
    if( _slaps == nil ) {
        NSLog(@"Intializing Inbox");
        _slaps = [[NSMutableArray alloc] init];
    }
    
    return _slaps;
}

+(void) addMessage:(Slap*) slap
{
    [self.slaps addObject: slap];
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
    return self.slaps;
}

+(void) removeMessageAtIndex:(NSInteger) index
{
    [_slaps removeObjectAtIndex: index];
}

//NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//NSString *deviceToken = [prefs objectForKey: @"deviceToken"];
//NSString *contact = [prefs objectForKey: @"contact"];

@end
