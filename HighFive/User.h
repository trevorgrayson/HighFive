//
//  User.h
//  HighFive
//
//  Created by Trevor Grayson on 8/1/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

-(id) init:(NSString*) name with:(NSString*) contact;

@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* contact;

-(NSString*) initials;

+(User*) identifiedBy:(NSString*) contact;
+(User*) named: (NSString*) name identifiedBy:(NSString*) contact;
@end
