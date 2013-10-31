//
//  DatabaseManager.h
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseManager : NSObject
{
    NSPersistentStoreCoordinator* _persistentStoreCoordinator;
    NSManagedObjectModel* _managedObjectModel;
    NSManagedObjectContext* _managedObjectContext;
}

+ (DatabaseManager*)sharedManager;
- (NSManagedObjectContext*)managedObjectContext;
- (void)saveContext;

@end
