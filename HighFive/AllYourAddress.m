//
//  AllYourAddress.m
//  RingRing
//
//  Created by Trevor Grayson on 1/4/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>
#import "AllYourAddress.h"
@implementation AllYourAddress

NSArray *contacts;

UIAlertView *alert;

+(void) isSharingContactsWithCallback:(void (^)(void))callback {
    if( ![self isSharingContacts]) {
        if (&ABAddressBookRequestAccessWithCompletion != NULL) {
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                if(granted) {
                    callback();
                }
            });
        }
    }
}

+(Boolean) isSharingContacts {
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        return NO;
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        return YES;
    }
    else {
        // The user has previously denied access
        if(alert == nil) {
            alert = [[UIAlertView alloc] initWithTitle:@"Can't access contacts" message:@"Hi Fives can't be sent without acess to your address book. Please update your settings in the Settings App." delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles: nil];
        }
        [alert show];
        
        return NO;
    }

}

+(NSArray*) contactsStartingWith:(NSString*) letter {

    NSPredicate* predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary* bindings) {
        NSString *first = CFBridgingRelease(ABRecordCopyValue((__bridge ABRecordRef)(record), kABPersonFirstNameProperty));
        
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

+(User*) contactAtIndex:(NSUInteger) index {
    //return CFArrayGetValueAtIndex([self addressBook], i);
    ABRecordRef record = (__bridge ABRecordRef)([[self allContacts] objectAtIndex: index]);
    return [self toUser:record];
}

+(User*) contactStartingWith:(NSString*) letter atIndex:(NSUInteger) index {
    ABRecordRef record = (__bridge ABRecordRef)([[self contactsStartingWith:letter] objectAtIndex: index]);
    return [self toUser:record];
}

+(ABAddressBookRef) addressBook {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    __block BOOL accessGranted = NO;
    
    if (&ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
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

+(User*) toUser:(ABRecordRef) ref {
    NSString *name = (__bridge NSString *)(ABRecordCopyValue(ref, kABPersonFirstNameProperty));
    ;
    //TODO Bigtime.
    NSString *contact = [self getContactNumber: ref];
    return [[User alloc] init:name with:contact];
}

+(NSString*) getContactNumber:(ABRecordRef) person {
    NSString* phone = @"";
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc] initWithObjects:@[@"", @""] forKeys:@[@"mobileNumber", @"homeNumber"]];
    
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSLog(@"Phone Count: %ld",  ABMultiValueGetCount(phones));
    for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
    {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phones, j);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phones, j);
        
        NSLog(@"Phone maybe (%@)", (__bridge NSString *)currentPhoneValue);
        if (j == 0) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            phone = (__bridge NSString *)currentPhoneValue;
        }
        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            phone = (__bridge NSString *)currentPhoneValue;
            continue;
        }
        
        if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"homeNumber"];
        }
        
        CFRelease(currentPhoneLabel);
        CFRelease(currentPhoneValue);
    }
    
    if ([phone isEqual:@""]) {
        phone = [contactInfoDict valueForKeyPath:@"homeNumber"];
    }
    
    phone = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789+"] invertedSet]] componentsJoinedByString:@""];
    NSLog(@"(%@)", phone);
    return phone;
}
@end
