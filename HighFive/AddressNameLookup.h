//
//  AddressLookup.h
//  HighFive
//
//  Created by Trevor Grayson on 9/14/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface AddressNameLookup : NSObject

+(NSString *)contactContainingPhoneNumber:(NSString *)phoneNumber;
+(NSArray *)contactsContainingPhoneNumber:(NSString *)phoneNumber;
@end
