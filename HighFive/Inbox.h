//
//  Inbox.h
//  HighFive
//
//  Created by Trevor Grayson on 1/8/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Slap.h"

@interface Inbox : NSObject

+(void) addMessage:(Slap*) slap;

+(NSInteger) count;
+(Slap*) messageAtIndex:(NSInteger) index;
+(NSArray*) messages;
@end
