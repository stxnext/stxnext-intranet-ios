//
//  RMUser+AddressBook.m
//  Intranet
//
//  Created by MK_STX on 12/11/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "RMUser+AddressBook.h"

@implementation RMUser (AddressBook)

- (BOOL)isInContacts
{
    return NO;
}

- (void)addToContacts
{
    if (![self isInContacts])
    {
        ABRecordRef user = ABPersonCreate();
        
        
        
        CFRelease(user);
    }
}

- (void)removeFromContacts
{
    if ([self isInContacts])
    {
        
    }
}

// to test, YES on success
- (BOOL)deleteAllContacts
{
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if (!error)
    {
        // error
        
        return NO;
    }
    
    CFArrayRef all = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex n = ABAddressBookGetPersonCount(addressBook);
    
    for (int i = 0; i < n; i++)
    {
        ABRecordRef ref = CFArrayGetValueAtIndex(all, i);
        ABAddressBookRemoveRecord(addressBook, ref, nil);
    }

    if (!ABAddressBookSave(addressBook, nil))
    {
        CFRelease(all);
        CFRelease(addressBook);
        
        return NO;
    }
    
    CFRelease(all);
    CFRelease(addressBook);
    
    return YES;
}

@end
