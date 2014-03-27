//
//  GMModel.m
//  Intranet
//
//  Created by Dawid Żakowski on 19/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "GMModel.h"

@implementation GMModel

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

@end

@implementation NSObject (ArrayMapping)

- (id)mapToModelWithType:(Class)modelType
{
    if (![modelType respondsToSelector:@selector(modelObjectWithDictionary:)])
        return nil;
    
    return [modelType performSelector:@selector(modelObjectWithDictionary:) withObject:self];
}

- (NSArray*)mapToArrayOfModelsWithType:(Class)modelType
{
    if (![self isKindOfClass:[NSArray class]])
        return nil;
    
    NSArray* rawArray = (NSArray*)self;
    NSMutableArray* mappings = [NSMutableArray array];
    
    for (id rawElement in rawArray)
    {
        id mappedElement = [rawElement mapToModelWithType:modelType];
        
        if (mappedElement)
            [mappings addObject:mappedElement];
    }
    
    return mappings;
}

- (id)validObject
{
    return ([self isKindOfClass:[NSNull class]]) ? nil : self;
}

- (NSNumber*)validNumber
{
    return ([self isKindOfClass:[NSNumber class]]) ? (NSNumber*)self : nil;
}

@end

@implementation NSDate (DateMapping)

- (NSNumber*)mapToTime
{
    return @((unsigned long long int)([self timeIntervalSince1970] * 1000));
}

@end

@implementation NSNumber (DateMapping)

- (NSDate*)mapToDate
{
    return [NSDate dateWithTimeIntervalSince1970:(self.unsignedLongLongValue / 1000)];
}

@end