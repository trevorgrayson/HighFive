//
//  AddressLookup.m
//  HighFive
//
//  Created by Trevor Grayson on 9/14/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "AddressNameLookup.h"

@implementation AddressNameLookup


+(NSString *)contactContainingPhoneNumber:(NSString *)phoneNumber {
    @try {
        return (__bridge NSString*)ABRecordCopyCompositeName( (__bridge ABRecordRef)[[self contactsContainingPhoneNumber:phoneNumber] objectAtIndex:0] );
    }
    @catch( NSException *e) {
        return phoneNumber;
    }

}

+(NSArray *)contactsContainingPhoneNumber:(NSString *)phoneNumber {
    // Remove non numeric characters from the phone number
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];

    // Create a new address book object with data from the Address Book database
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (!addressBook) {
        return [NSArray array];
    } else if (error) {
        CFRelease(addressBook);
        return [NSArray array];
    }
    
    // Requests access to address book data from the user
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {});
    
    // Build a predicate that searches for contacts that contain the phone number
    NSPredicate *predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary *bindings) {
        ABMultiValueRef phoneNumbers = ABRecordCopyValue( (__bridge ABRecordRef)record, kABPersonPhoneProperty);
        BOOL result = NO;
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            NSString *contactPhoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            contactPhoneNumber = [[contactPhoneNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
            if ([contactPhoneNumber rangeOfString:phoneNumber].location != NSNotFound) {
                result = YES;
                break;
            }
        }
        CFRelease(phoneNumbers);
        return result;
    }];
    
    // Search the users contacts for contacts that contain the phone number
    NSArray *allPeople = (NSArray *)CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSArray *filteredContacts = [allPeople filteredArrayUsingPredicate:predicate];
    CFRelease(addressBook);

    return filteredContacts;
}

@end
