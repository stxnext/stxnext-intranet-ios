//
//  RMUser+AddressBook.m
//  Intranet
//
//  Created by MK_STX on 12/11/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "RMUser+AddressBook.h"
#import "AddressBookManager.h"

@implementation RMUser (AddressBook)

+ (NSString*)stringForProperty:(ABPropertyID)property inRecord:(ABRecordRef)record
{
    CFStringRef stringRef = ABRecordCopyValue(record, property);
    NSString* value = stringRef ? [NSString stringWithFormat:@"%@", stringRef] : nil;
    
    if (stringRef) CFRelease(stringRef);
    
    return value;
}

+ (NSString*)fullNameForPerson:(ABRecordRef)person
{
    NSString* firstName = [RMUser stringForProperty:kABPersonFirstNameProperty inRecord:person];
    NSString* lastName = [RMUser stringForProperty:kABPersonLastNameProperty inRecord:person];
    
    NSMutableString* name = [NSMutableString string];
    if (firstName) [name appendString:firstName];
    if (lastName) [name appendString:[NSString stringWithFormat:@" %@", lastName]];
    
    return name;
}

- (BOOL)isInContacts
{
    __block BOOL result = NO;
    
    [AddressBookManager requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBook, BOOL available) {
        if (available && addressBook)
        {
            CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
            CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
            
            for (int i = 0; i < numberOfPeople; i++)
            {
                NSString *name = [RMUser fullNameForPerson:CFArrayGetValueAtIndex(allPeople, i)];
                
                if ([name caseInsensitiveCompare:self.name] == NSOrderedSame)
                {
                    result = YES;
                    
                    break;
                }
            }
            
            if (allPeople)
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
        [AddressBookManager requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBook, BOOL available) {
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
                    if (multiPhone) CFRelease(multiPhone);
                }
                
                ABAddressBookAddRecord(addressBook, newPerson, &error);
                
                if (newPerson) CFRelease(newPerson);
                
                if (error != NULL)
                {
                    CFStringRef errorDesc = CFErrorCopyDescription(error);
                    NSLog(@"Contact not added: %@", errorDesc);
                    if (errorDesc) CFRelease(errorDesc);
                }
                else
                {
                    ABAddressBookSave(addressBook, &error);
                    
                    if (error != NULL)
                    {
                        CFStringRef errorDesc = CFErrorCopyDescription(error);
                        NSLog(@"Contact not saved: %@", errorDesc);
                        if (errorDesc) CFRelease(errorDesc);
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
        [AddressBookManager requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBook, BOOL available) {
            if (available && addressBook)
            {
                CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
                CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
                
                BOOL found = NO;
                for (int i = 0; i < numberOfPeople; i++)
                {
                    NSString* name = [RMUser fullNameForPerson:CFArrayGetValueAtIndex(allPeople, i)];
                    
                    if ([name caseInsensitiveCompare:self.name] == NSOrderedSame)
                    {
                        found = YES;
                        
                        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
                        ABAddressBookRemoveRecord(addressBook, ref, nil);
                        break;
                    }
                }

                if (allPeople) CFRelease(allPeople);
                
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
    [AddressBookManager requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBook, BOOL available) {
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
            
            if (allPeople) CFRelease(allPeople);
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
    [AddressBookManager requestAddressBookWithCompletionHandler:^(ABAddressBookRef addressBook, BOOL available) {
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
            
            if (allPeople) CFRelease(allPeople);
        }
        else
        {
            NSLog(@"AB INAVAILABLE");
        }
    }];
}

@end
