//
//  RMAbsence+Additions.m
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "RMAbsence+Additions.h"

@implementation RMAbsence (Additions)

#pragma mark Mapping

const NSString* MapKeyAbsenceId = @"absence_id";
const NSString* MapKeyAbsenceStart = @"start";
const NSString* MapKeyAbsenceStop = @"end";
const NSString* MapKeyAbsenceRemarks = @"remarks";
const NSString* MapKeyAbsenceUserId = @"id";
const NSString* MapKeyAbsenceUserName = @"name";

#pragma mark Serialization

+ (NSString*)coreDataEntityName
{
    return @"Absence";
}

+ (NSManagedObject<JSONMapping>*)mapFromJSON:(id)json
{
//    DDLogVerbose(@"%@", json);
    
    return [JSONSerializationHelper objectWithClass:[self class]
                                             withId:json[MapKeyUserId]
                                   inManagedContext:[DatabaseManager sharedManager].managedObjectContext
                                      withDecorator:^(NSManagedObject<JSONMapping>* object) {
                                          RMAbsence* absence = (RMAbsence*)object;
                                          absence.id = [json[MapKeyAbsenceId] validObject];
                                          absence.start = [JSONSerializationHelper dateFromJSONObject:[json[MapKeyAbsenceStart] validObject] withDateFormat:@"dd.MM.yy"];
                                          absence.stop = [JSONSerializationHelper dateFromJSONObject:[json[MapKeyAbsenceStop] validObject] withDateFormat:@"dd.MM.yy"];
                                          absence.remarks = [json[MapKeyAbsenceRemarks] validObject];
                                          absence.user = (RMUser*)[JSONSerializationHelper objectWithClass:[RMUser class]
                                                                                                    withId:[json[MapKeyAbsenceUserId] validObject]
                                                                                          inManagedContext:[DatabaseManager sharedManager].managedObjectContext
                                                                                             withDecorator:^(NSManagedObject<JSONMapping> *object) {
//                                                                                                 RMUser* user = (RMUser*)object;
//                                                                                                 user.name = [json[MapKeyAbsenceUserName] validObject];
                                                                                             }];
                                          [absence.user addAbsencesObject:absence];
                                      }];
}

- (id)mapToJSON
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Method %@ not implemented", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end