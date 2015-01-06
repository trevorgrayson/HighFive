//
//  AllYourAddress.h
//  RingRing
//
//  Created by Trevor Grayson on 1/4/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface AllYourAddress : NSObject

+(NSArray*) allContacts;

+(NSUInteger) allContactsCount;

+(ABRecordRef) contactAtIndex:(NSUInteger) index;
@end
