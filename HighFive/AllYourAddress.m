//
//  AllYourAddress.m
//  RingRing
//
//  Created by Trevor Grayson on 1/4/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import "AllYourAddress.h"
@implementation AllYourAddress

NSArray *contacts;

+(NSArray*) contactsStartingWith:(NSString*) letter {

    NSPredicate* predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary* bindings) {
        NSString *first = (__bridge NSString *)(ABRecordCopyValue((__bridge ABRecordRef)(record), kABPersonFirstNameProperty));
        
        return [first hasPrefix:letter];
    }];
    
    return [[self allContacts] filteredArrayUsingPredicate:predicate];
}

+(NSInteger) contactsStartingWithCount: (NSString*) letter {
    NSArray *a = [self contactsStartingWith:letter];
    return [a count];
}

+(NSArray*) allContacts {
    if (!contacts) {
        contacts = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering([self addressBook], kABSourceTypeLocal, kABPersonSortByFirstName));
    }
    return contacts;
}

//+(void) refresh;
//+(void) destroy;

+(ABRecordRef) contactAtIndex:(NSUInteger) index {
    //return CFArrayGetValueAtIndex([self addressBook], i);
    return (__bridge ABRecordRef)([[self allContacts] objectAtIndex: index]);
}

+(ABAddressBookRef) addressBook {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(sema);
        });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted) {
        return addressBook;
    } else {
        return nil;
    }
}

+(NSUInteger) allContactsCount  { return ABAddressBookGetPersonCount([self addressBook]); }

@end
