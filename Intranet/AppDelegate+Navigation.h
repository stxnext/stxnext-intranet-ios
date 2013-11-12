//
//  AppDelegate+Navigation.h
//  Intranet
//
//  Created by MK_STX on 12/11/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "AppDelegate.h"

typedef enum
{
    TabIndexUserList,
    TabIndexSettings
} TabIndex;

@interface AppDelegate (Navigation)

- (void)goToTabAtIndex:(NSUInteger)index;

@end
