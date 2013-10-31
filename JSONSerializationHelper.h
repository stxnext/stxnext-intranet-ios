//
//  JSONSerializationHelper.h
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol JSONMapping <NSObject>

#pragma mark Serialization

+ (NSString*)coreDataEntityName;
+ (NSManagedObject<JSONMapping>*)mapFromJSON:(id)json;
- (id)mapToJSON;

@end

@interface JSONSerializationHelper : NSObject

#pragma mark Helpers

+ (NSManagedObject<JSONMapping>*)objectWithClass:(Class<JSONMapping>)class
                                          withId:(NSNumber*)id
                                inManagedContext:(NSManagedObjectContext*)context
                           withCreationDecorator:(void (^)(NSManagedObject<JSONMapping>* object))creationDecorator;

+ (NSArray*)objectsWithClass:(Class<JSONMapping>)class
          withSortDescriptor:(NSSortDescriptor*)sortDescriptor
               withPredicate:(NSPredicate*)predicate
            inManagedContext:(NSManagedObjectContext*)context;

+ (void)deleteObjectsWithClass:(Class<JSONMapping>)class inManagedContext:(NSManagedObjectContext*)context;

+ (NSDate*)dateFromJSONObject:(id)jsonObject withDateFormat:(NSString*)dateFormat;

@end

@interface NSObject (JSONHelper)

- (id)validObject;

@end