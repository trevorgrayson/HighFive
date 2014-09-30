//
//  HighFiveTests.m
//  HighFiveTests
//
//  Created by Trevor Grayson on 7/18/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "AddressNameLookup.h"

@interface HighFiveTests : XCTestCase

@end

@implementation HighFiveTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    //XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    [self addContact:@"Trevor" withNumber:@"8603849759"];
    [self addContact:@"Paul" withNumber:@"8605559759"];
    NSLog(@"%@", [AddressNameLookup contactContainingPhoneNumber:@"8603849759"]);
}

- (void) testAddressLookup {
    [self addContact:@"Trevor" withNumber:@"8603849759"];
    [self addContact:@"Paul" withNumber:@"8605559759"];
    NSLog(@"%@", [AddressNameLookup contactContainingPhoneNumber:@"8603849759"]);

}

- (void) addContact:(NSString*) name withNumber:(NSString*) contact {
    CFErrorRef error = NULL;
    NSLog(@"%@", [self description]);
    ABAddressBookRef iPhoneAddressBook = ABAddressBookCreate();
    
    ABRecordRef newPerson = ABPersonCreate();
    
    ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)(name), &error);
    ABRecordSetValue(newPerson, kABPersonLastNameProperty, @"Smith", &error);
    
    ABMutableMultiValueRef multiPhone =     ABMultiValueCreateMutable(kABMultiStringPropertyType);

    ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFTypeRef)(contact), kABPersonPhoneMainLabel, NULL);
    //ABMultiValueAddValueAndLabel(multiPhone, people.other, kABOtherLabel, NULL);
    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone,nil);
    CFRelease(multiPhone);
    // ...
    // Set other properties
    // ...
    ABAddressBookAddRecord(iPhoneAddressBook, newPerson, &error);
    
    ABAddressBookSave(iPhoneAddressBook, &error);
    CFRelease(newPerson);
    CFRelease(iPhoneAddressBook);
    if (error != NULL)
    {
        CFStringRef errorDesc = CFErrorCopyDescription(error);
        NSLog(@"Contact not saved: %@", errorDesc);
        CFRelease(errorDesc);        
    }
}
@end
