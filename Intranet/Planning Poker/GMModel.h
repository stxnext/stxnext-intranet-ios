//
//  GMModel.h
//  Intranet
//
//  Created by Dawid Żakowski on 19/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GMModelProtocol <NSObject>

@required
+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end

@interface GMModel : NSObject <GMModelProtocol, NSCoding, NSCopying>

@end

@interface NSObject (ArrayMapping)

- (id)mapToModelWithType:(Class)modelType;
- (NSArray*)mapToArrayOfModelsWithType:(Class)modelType;
- (id)validObject;
- (NSNumber*)validNumber;

@end

@interface NSDate (DateMapping)

- (NSNumber*)mapToTime;

@end

@interface NSNumber (DateMapping)

- (NSDate*)mapToDate;

@end