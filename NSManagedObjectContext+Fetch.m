//
//  NSManagedObjectContext+Fetch.m
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "NSManagedObjectContext+Fetch.h"

@implementation NSManagedObjectContext (Fetch)

- (NSArray *)fetchObjectsForEntityName:(NSString*)entityName
                   withSortDescriptor:(NSSortDescriptor*)sortDescriptor
                        withPredicate:(NSPredicate*)predicate
                            withLimit:(NSNumber*)limit
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    if (limit)
        [request setFetchLimit:limit.integerValue];
    
    if (sortDescriptor)
        [request setSortDescriptors:@[ sortDescriptor ]];
    
    if (predicate)
        [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self executeFetchRequest:request error:&error];
    
    if (error)
    {
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    return fetchedObjects;
}

- (id)fetchObjectForEntityName:(NSString*)entityName
            withSortDescriptor:(NSSortDescriptor*)sortDescriptor
                 withPredicate:(NSPredicate*)predicate
{
    return [self fetchObjectsForEntityName:entityName withSortDescriptor:sortDescriptor withPredicate:predicate withLimit:@( 1 )].lastObject;
}

@end
