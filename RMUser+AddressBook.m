//
//  RMUser+AddressBook.m
//  Intranet
//
//  Created by MK_STX on 12/11/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "RMUser+AddressBook.h"

typedef void (^AddressbookRequestHandler)(ABAddressBookRef addressBook, BOOL available);

@implementation RMUser (AddressBook)

- (BOOL)isInContacts
{
    __block BOOL result = NO;
    
    [self requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBook, BOOL available) {
        if (available && addressBook)
        {
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
            CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
            
            for (int i = 0; i < numberOfPeople; i++)
            {
                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                
                CFStringRef firstName = (ABRecordCopyValue(person, kABPersonFirstNameProperty));
                CFStringRef lastName = (ABRecordCopyValue(person, kABPersonLastNameProperty));
                
                CFStringRef strs[2] = { firstName, lastName };
                CFArrayRef strsArray = CFArrayCreate(NULL, (void *)strs, 2, &kCFTypeArrayCallBacks);

                CFRelease(firstName);
                CFRelease(lastName);
                
                CFStringRef name = CFStringCreateByCombiningStrings(NULL, strsArray, CFSTR(" "));
                
                CFRelease(strsArray);
                
                if (CFStringCompare(name, (__bridge CFStringRef)self.name, kCFCompareCaseInsensitive) == kCFCompareEqualTo) // found
                {
                    result = YES;
                    CFRelease(name);
                    break;
                }
                
                CFRelease(name);
            }
            
            CFRelease(allPeople);
        }
        else
        {
            NSLog(@"AB INAVAILABLE");
        }
    }];
    
    return result;
}

- (void)addToContacts
{
    if (![self isInContacts])
    {
        [self requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBook, BOOL available) {
            if (available && addressBook)
            {
                CFErrorRef error = NULL;
                
                ABRecordRef newPerson = ABPersonCreate();
                
                if (self.name != nil)
                {
                    NSArray *names = [self.name componentsSeparatedByString:@" "];
                    
                    NSString *firstName = nil, *lastName = nil;
                    
                    if (names.count > 0)
                    {
                        firstName = names[0];
                        
                        if (names.count > 1)
                        {
                            lastName = names[1];
                        }
                    }
                    
                    if (firstName != nil)
                    {
                        ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFStringRef)firstName, &error);
                    }
                    
                    if (lastName != nil)
                    {
                        ABRecordSetValue(newPerson, kABPersonLastNameProperty, (__bridge CFStringRef)lastName, &error);
                    }
                }
                
                // TO DO: add other types of phone numbers with labels
                if (self.phone != nil)
                {
                    ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                    ABMultiValueAddValueAndLabel(multiPhone, (__bridge CFStringRef)self.phone, kABPersonPhoneMainLabel, NULL);
                    ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone, &error);
                    CFRelease(multiPhone);
                }
                
                ABAddressBookAddRecord(addressBook, newPerson, &error);
                CFRelease(newPerson);
                
                if (error != NULL)
                {
                    CFStringRef errorDesc = CFErrorCopyDescription(error);
                    NSLog(@"Contact not added: %@", errorDesc);
                    CFRelease(errorDesc);
                }
                else
                {
                    ABAddressBookSave(addressBook, &error);
                    
                    if (error != NULL)
                    {
                        CFStringRef errorDesc = CFErrorCopyDescription(error);
                        NSLog(@"Contact not saved: %@", errorDesc);
                        CFRelease(errorDesc);
                    }
                }
            }
        }];
    }
}

- (void)removeFromContacts
{
    if ([self isInContacts])
    {
        [self requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBook, BOOL available) {
            if (available && addressBook)
            {
                CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
                CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
                
                BOOL found = NO;
                for (int i = 0; i < numberOfPeople; i++)
                {
                    ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                    
                    CFStringRef firstName = (ABRecordCopyValue(person, kABPersonFirstNameProperty));
                    CFStringRef lastName = (ABRecordCopyValue(person, kABPersonLastNameProperty));
                    
                    CFStringRef strs[2] = { firstName, lastName };
                    CFArrayRef strsArray = CFArrayCreate(NULL, (void *)strs, 2, &kCFTypeArrayCallBacks);
                    
                    CFRelease(firstName);
                    CFRelease(lastName);
                    
                    CFStringRef name = CFStringCreateByCombiningStrings(NULL, strsArray, CFSTR(" "));
                    
                    CFRelease(strsArray);
                    
                    if (CFStringCompare(name, (__bridge CFStringRef)self.name, kCFCompareCaseInsensitive) == kCFCompareEqualTo) // found
                    {
                        found = YES;
                        
                        CFRelease(name);
                        
                        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
                        ABAddressBookRemoveRecord(addressBook, ref, nil);
                        break;
                    }
                    
                    CFRelease(name);
                }

                CFRelease(allPeople);
                
                if (found)
                {
                    if (!ABAddressBookSave(addressBook, nil))
                    {
                        
                    }
                }
            }
            else
            {
                NSLog(@"AB INAVAILABLE");
            }
        }];
    }
}

// to test, YES on success
- (void)deleteAllContacts
{
    [self requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBook, BOOL available) {
        if (available && addressBook)
        {
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
            CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
            
            for (int i = 0; i < numberOfPeople; i++)
            {
                ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
                ABAddressBookRemoveRecord(addressBook, ref, nil);
            }
            
            if (!ABAddressBookSave(addressBook, nil))
            {
                
            }
            
            CFRelease(allPeople);
        }
        else
        {
            NSLog(@"AB INAVAILABLE");
        }
    }];
}

// to test
- (void)listAllContacts
{
    [self requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBook, BOOL available) {
        if (available && addressBook)
        {
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
            CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
            
            for (int i = 0; i < numberOfPeople; i++)
            {
                ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
                
                NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
                NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
                
                NSLog(@"Name: %@ %@", firstName, lastName);
                
                ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
                
                for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++)
                {
                    NSString *phoneNumber = (__bridge NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
                    NSLog(@"phone: %@", phoneNumber);
                }
                
                NSLog(@"=============================================");
            }
            
            CFRelease(allPeople);
        }
        else
        {
            NSLog(@"AB INAVAILABLE");
        }
    }];
}

#pragma mark - Address Book Management

- (BOOL)isAddressBookAvailable
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    return (status == kABAuthorizationStatusAuthorized);
}

- (void)requestAddressBookWithCompletionHandler:(AddressbookRequestHandler)handler
{
    if (ABAddressBookRequestAccessWithCompletion != NULL) // we're on iOS6
    {
        CFErrorRef error = NULL;
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
        
        ABAuthorizationStatus curStatus = ABAddressBookGetAuthorizationStatus();
        
        if (curStatus == kABAuthorizationStatusNotDetermined)
        {
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                dispatch_semaphore_signal(sem);
                
                if (handler != NULL)
                {
                    handler(addressBookRef, [self isAddressBookAvailable]);
                }
                
                if (addressBookRef)
                {
                    CFRelease(addressBookRef);
                }
            });
            
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        }
        else
        {
            if (handler != NULL)
            {
                handler(addressBookRef, [self isAddressBookAvailable]);
            }
            
            if (addressBookRef)
            {
                CFRelease(addressBookRef);
            }
        }
    }
}

@end
