//
//  UIViewController+QuickObservers.h
//  Intranet
//
//  Created by Dawid Żakowski on 09/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "UIViewController+QuickObservers.h"

@implementation UIViewController (Observers)

#pragma mark - Getters/Setters
- (NSMutableDictionary*)quickObservers
{
    if (!objc_getAssociatedObject(self, @selector(quickObservers)))
        self.quickObservers = [NSMutableDictionary dictionary];
    
    return objc_getAssociatedObject(self, @selector(quickObservers));
}

- (void)setQuickObservers:(NSMutableDictionary*)quickObservers
{
    objc_setAssociatedObject(self, @selector(quickObservers), quickObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Logic
- (void)addQuickObserverForNotificationWithKey:(NSString*)notificationKey withBlock:(void (^)(NSNotification *note))block;
{
    id observer = [[NSNotificationCenter defaultCenter] addObserverForName:notificationKey object:nil queue:nil usingBlock:block];
    
    @synchronized (self)
    {
        NSMutableArray* observerList = self.quickObservers[notificationKey] ?: [NSMutableArray array];
        [observerList addObject:observer];
        self.quickObservers[notificationKey] = observerList;
    }
}

- (void)removeQuickObservers
{
    @synchronized (self)
    {
        for (NSString* key in self.quickObservers.allKeys)
        {
            NSArray* observerList = self.quickObservers[key];
            
            for (id observer in observerList)
                [[NSNotificationCenter defaultCenter] removeObserver:observer name:key object:nil];
        }
        
        self.quickObservers = [NSMutableDictionary dictionary];
    }
}

@end
