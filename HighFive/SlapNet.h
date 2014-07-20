//
//  SlapNet.h
//  HighFive
//
//  Created by Trevor Grayson on 7/19/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface SlapNet : NSObject<MFMessageComposeViewControllerDelegate>

-(void) sendSlap:(double) ferocity to:(NSString*) contact;
@end
