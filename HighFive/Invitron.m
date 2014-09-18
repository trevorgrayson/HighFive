//
//  Invitron.m
//  HighFive
//
//  Created by Trevor Grayson on 9/15/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "Invitron.h"

@implementation Invitron

NSString *inviteUrl = @"http://ipsumllc.com:8080/invite/%@";

+(NSString*) inviteUrlFor:(NSString*) contact {
    NSData   *nsdata = [contact dataUsingEncoding: NSUTF8StringEncoding];
    NSString *base64 = [nsdata base64EncodedStringWithOptions:0];
    return [NSString stringWithFormat:inviteUrl, base64];
}

// Let's go the other way...
//
//// NSData from the Base64 encoded str
//NSData *nsdataFromBase64String = [[NSData alloc]
//                                  initWithBase64EncodedString:base64Encoded options:0];
//
//// Decoded NSString from the NSData
//NSString *base64Decoded = [[NSString alloc]
//                           initWithData:nsdataFromBase64String encoding:NSUTF8StringEncoding];
//NSLog(@"Decoded: %@", base64Decoded);
@end
