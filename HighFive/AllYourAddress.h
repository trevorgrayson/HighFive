//
//  AllYourAddress.h
//  RingRing
//
//  Created by Trevor Grayson on 1/4/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "User.h"

@interface AllYourAddress : NSObject

+(NSArray*) allContacts;
+(NSUInteger) allContactsCount;

+(NSArray*) contactsStartingWith:(NSString*) letter;
+(NSInteger) contactsStartingWithCount: (NSString*) letter;

+(User*) contactAtIndex:(NSUInteger) index;

+(User*) contactStartingWith:(NSString*) letter atIndex:(NSUInteger) index;
@end
