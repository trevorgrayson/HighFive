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

@property (weak, nonatomic) User *slapper;
@property double ferocity;
@end
