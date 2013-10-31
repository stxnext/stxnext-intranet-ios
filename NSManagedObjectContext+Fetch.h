//
//  NSManagedObjectContext+Fetch.h
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Fetch)

- (NSArray*)fetchObjectsForEntityName:(NSString*)entityName
                   withSortDescriptor:(NSSortDescriptor*)sortDescriptor
                        withPredicate:(NSPredicate*)predicate
                            withLimit:(NSNumber*)limit;

- (id)fetchObjectForEntityName:(NSString*)entityName
                  withSortDescriptor:(NSSortDescriptor*)sortDescriptor
                       withPredicate:(NSPredicate*)predicate;

@end
