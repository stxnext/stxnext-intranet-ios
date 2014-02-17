
//
//  JSONSerializationHelper.m
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "JSONSerializationHelper.h"

@implementation JSONSerializationHelper

#pragma mark Helpers

+ (NSManagedObject<JSONMapping> *)objectWithClass:(Class<JSONMapping>)class
                                           withId:(NSNumber *)id
inManagedContext:(NSManagedObjectContext *)context
withDecorator:(void (^)(NSManagedObject<JSONMapping> *object))decorator;
{
    NSManagedObject<JSONMapping> *object = (NSManagedObject<JSONMapping>*)[context fetchObjectForEntityName:[class coreDataEntityName]
                                                                                         withSortDescriptor:nil
                                                                                              withPredicate:[NSPredicate predicateWithFormat:@"id = %d", id.integerValue]];
    
    if (decorator)
        decorator(object);
    
    if (object)
        return object;
    
    object = [NSEntityDescription insertNewObjectForEntityForName:[class coreDataEntityName] inManagedObjectContext:context];
    [object setValue:id forKey:@"id"];
    
    if (decorator)
        decorator(object);
    
    return object;
}

+ (NSArray*)objectsWithClass:(Class<JSONMapping>)class
          withSortDescriptor:(NSSortDescriptor*)sortDescriptor
               withPredicate:(NSPredicate*)predicate
            inManagedContext:(NSManagedObjectContext*)context
{
    return [context fetchObjectsForEntityName:[class coreDataEntityName]
                           withSortDescriptor:sortDescriptor
                                withPredicate:predicate
                                    withLimit:nil];
}

+ (void)deleteObjectsWithClass:(Class<JSONMapping>)class inManagedContext:(NSManagedObjectContext*)context
{
    NSArray *objects = [self objectsWithClass:class withSortDescriptor:nil withPredicate:nil inManagedContext:context];
    
    for (NSManagedObject* object in objects)
        [context deleteObject:object];
}

+ (NSDate *)dateFromJSONObject:(id)jsonObject withDateFormat:(NSString*)dateFormat
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:dateFormat];
    
    return [formatter dateFromString:jsonObject];
}

@end

@implementation NSObject (JSONHelper)

- (id)validObject
{
    return ([self isKindOfClass:[NSNull class]]) ? nil : self;
}

@end