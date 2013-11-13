//
//  RMUser+AddressBook.h
//  Intranet
//
//  Created by MK_STX on 12/11/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "RMUser.h"

@interface RMUser (AddressBook)

- (BOOL)isInContacts;
- (void)addToContacts;
- (void)removeFromContacts;

// to test
- (void)deleteAllContacts;
- (void)listAllContacts;

@end
