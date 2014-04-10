//
//  UIViewController+QuickObservers.h
//  Intranet
//
//  Created by Dawid Żakowski on 09/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (QuickObservers)

@property (nonatomic, strong) NSMutableDictionary* quickObservers;

- (void)addQuickObserverForNotificationWithKey:(NSString*)notificationKey withBlock:(void (^)(NSNotification *note))block;
- (void)removeQuickObservers;

@end
