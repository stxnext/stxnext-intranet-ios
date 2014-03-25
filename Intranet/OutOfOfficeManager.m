//
//  OutOfOfficeManager.m
//  Intranet
//
//  Created by Adam on 25.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "OutOfOfficeManager.h"

@interface OutOfOfficeManager ()

@property (nonatomic, strong) NSMutableArray *userList;

@end

@implementation OutOfOfficeManager

- (void)addUser:(RMUser *)user
{
    [self.userList addObject:user];
}

- (RMUser *)userAtIndex:(NSUInteger)index
{
    if (index < self.userList.count)
    {
        return self.userList[index];
    }
    
    return nil;
}

- (NSMutableArray *)userList
{
    if (!_userList)
    {
        _userList = [NSMutableArray new];
    }
    
    return _userList;
}

- (NSUInteger)count
{
    return self.userList.count;
}

@end
