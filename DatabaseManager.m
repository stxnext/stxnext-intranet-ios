//
//  DatabaseManager.m
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "DatabaseManager.h"

@implementation DatabaseManager

static DatabaseManager *_sharedManager = nil;

+ (DatabaseManager *)sharedManager
{
    return _sharedManager ?: (_sharedManager = [DatabaseManager new]);
}

#pragma mark Database

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Database" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Database.sqlite"];
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption:       @YES,
                              };
    
    NSError *error;
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        
        return nil;
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    if (_managedObjectContext == nil)
    {
        return;
    }
    
    NSError *error;
    
    if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error])
    {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

@end
