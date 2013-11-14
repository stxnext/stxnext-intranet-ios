//
//  AddressBookManager.m
//  Intranet
//
//  Created by MK_STX on 13/11/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "AddressBookManager.h"

@implementation AddressBookManager

+ (BOOL)isAddressBookAvailable
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    return (status == kABAuthorizationStatusAuthorized);
}

+ (void)requestAddressBookWithCompletionHandler:(AddressbookRequestHandler)handler
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
