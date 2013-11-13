//
//  AddressBookManager.h
//  Intranet
//
//  Created by MK_STX on 13/11/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

typedef void (^AddressbookRequestHandler)(ABAddressBookRef addressBook, BOOL available);

@interface AddressBookManager : NSObject

+ (BOOL)isAddressBookAvailable;
+ (void)requestAddressBookWithCompletionHandler:(AddressbookRequestHandler)handler;

@end
