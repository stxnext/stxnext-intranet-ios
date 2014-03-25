//
//  OutOfOfficeManager.h
//  Intranet
//
//  Created by Adam on 25.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutOfOfficeManager : NSObject

- (void)addUser:(RMUser *)user;
- (RMUser *)userAtIndex:(NSUInteger)index;
- (NSUInteger)count;

@end
