//
//  RMLate+Additions.m
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "RMLate+Additions.h"

@implementation RMLate (Additions)

#pragma mark Mapping

const NSString* MapKeyLateId = @"late_id";
const NSString* MapKeyLateStart = @"start";
const NSString* MapKeyLateStop = @"end";
const NSString* MapKeyLateExplanation = @"explanation";
const NSString* MapKeyLateIsWorkingFromHome = @"work_from_home";
const NSString* MapKeyLateUserId = @"id";
const NSString* MapKeyLateUserName = @"name";

#pragma mark Serialization

+ (NSString*)coreDataEntityName
{
    return @"Late";
}

+ (NSManagedObject<JSONMapping>*)mapFromJSON:(id)json
{
    DDLogVerbose(@"%@", json);
    return [JSONSerializationHelper objectWithClass:[self class]
                                             withId:json[MapKeyUserId]
                                   inManagedContext:[DatabaseManager sharedManager].managedObjectContext
                                      withDecorator:^(NSManagedObject<JSONMapping>* object) {
                                          RMLate* late = (RMLate*)object;
                                          late.id = [json[MapKeyLateId] validObject];
                                          late.start = [JSONSerializationHelper dateFromJSONObject:[json[MapKeyLateStart] validObject] withDateFormat:@"HH:mm"];
                                          late.stop = [JSONSerializationHelper dateFromJSONObject:[json[MapKeyLateStop] validObject] withDateFormat:@"HH:mm"];
                                          late.explanation = [json[MapKeyLateExplanation] validObject];
                                          late.isWorkingFromHome = [json[MapKeyLateIsWorkingFromHome] validObject];
                                          late.user = (RMUser*)[JSONSerializationHelper objectWithClass:[RMUser class]
                                                                                                 withId:[json[MapKeyLateUserId] validObject]
                                                                                       inManagedContext:[DatabaseManager sharedManager].managedObjectContext
                                                                                          withDecorator:^(NSManagedObject<JSONMapping> *object) {
//                                                                                              RMUser* user = (RMUser*)object;
//                                                                                              user.name = [json[MapKeyLateUserName] validObject];
                                                                                          }];
                                          [late.user addLatesObject:late];
                                      }];
}

- (id)mapToJSON
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Method %@ not implemented", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end