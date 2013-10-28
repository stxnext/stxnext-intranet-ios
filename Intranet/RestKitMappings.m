//
//  RestKitMappings.m
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "RestKitMappings.h"

typedef enum {
    RKObjectMappingRequest = 0,
    RKObjectMappingResponse,
} RKObjectMappingType;

@interface RMGeneric ()

+ (RKObjectMapping*)mappingForType:(RKObjectMappingType)type;
+ (void)handleMappingType:(RKObjectMappingType)type forMapping:(RKObjectMapping*)mapping;

@end

@implementation RMGeneric

+ (id)performStaticSelector:(SEL)selector onClass:(Class)class
{
    if (![class isSubclassOfClass:[RMGeneric class]] || ![class respondsToSelector:selector])
        return nil;
    
    return [class performSelector:selector];
}

+ (RKObjectMapping*)requestMappingForClass:(Class)class;
{
    return [RMGeneric performStaticSelector:@selector(requestMapping) onClass:class];
}

+ (RKObjectMapping*)responseMappingForClass:(Class)class;
{
    return [RMGeneric performStaticSelector:@selector(responseMapping) onClass:class];
}

+ (RKObjectMapping*)baseMappingForType:(RKObjectMappingType)type
{
    return (type == RKObjectMappingRequest) ? [RKObjectMapping requestMapping] : [RKObjectMapping mappingForClass:[self class]];
}

+ (RKObjectMapping*)requestMapping
{
    RKObjectMapping* mapping = [self mappingForType:RKObjectMappingRequest];
    [RMGeneric handleMappingType:RKObjectMappingRequest forMapping:mapping];
    
    return mapping;
}

+ (RKObjectMapping*)responseMapping
{
    RKObjectMapping* mapping = [self mappingForType:RKObjectMappingResponse];
    [RMGeneric handleMappingType:RKObjectMappingResponse forMapping:mapping];
    
    return mapping;
}

- (RKObjectMapping*)requestMapping
{
    return [RMGeneric requestMappingForClass:[self class]];
}

- (RKObjectMapping*)responseMapping
{
    return [RMGeneric responseMappingForClass:[self class]];
}

// This method inverses mapping for Request type basing on Response type mapping given by default
+ (void)handleMappingType:(RKObjectMappingType)type forMapping:(RKObjectMapping*)mapping
{
    if (type == RKObjectMappingResponse)
        return;
    
    for (RKPropertyMapping* propertyMapping in [mapping.propertyMappings copy])
    {
        RKPropertyMapping* invertedMapping;
        
        if ([propertyMapping isKindOfClass:[RKRelationshipMapping class]])
        {
            RKRelationshipMapping* relationship = (RKRelationshipMapping*)propertyMapping;
            
            invertedMapping = [RKRelationshipMapping relationshipMappingFromKeyPath:relationship.destinationKeyPath
                                                                          toKeyPath:relationship.sourceKeyPath
                                                                        withMapping:relationship.mapping];
        }
        else if ([propertyMapping isKindOfClass:[RKAttributeMapping class]])
        {
            RKAttributeMapping* attribute = (RKAttributeMapping*)propertyMapping;
            
            invertedMapping = [RKAttributeMapping attributeMappingFromKeyPath:attribute.destinationKeyPath
                                                                    toKeyPath:attribute.sourceKeyPath];
        }
        else
            continue;
        
        [mapping removePropertyMapping:propertyMapping];
        [mapping addPropertyMapping:invertedMapping];
    }
}

+ (RKObjectMapping*)mappingForType:(RKObjectMappingType)type
{
    return nil;
}

- (NSString*)description
{
    NSMutableDictionary* properties = [NSMutableDictionary dictionary];
    NSArray* propertyNames = [self responseMapping].propertyMappingsByDestinationKeyPath.allKeys;
    
    for (NSString* propertyName in propertyNames)
    {
        [properties setObject:[self valueForKey:propertyName] ?: @""
                       forKey:propertyName];
    }
    
    return [properties description];
}

@end

@implementation RMUser

+ (RKObjectMapping*)mappingForType:(RKObjectMappingType)type
{
    RKObjectMapping* mapping = [self baseMappingForType:type];
    
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id":                    @"id",
                                                  @"name":                  @"name",
                                                  @"img":                   @"imageURL",
                                                  @"avatar_url":            @"avatarURL",
                                                  @"location":              @"location",
                                                  @"freelancer":            @"isFreelancer",
                                                  @"is_client":             @"isClient",
                                                  @"is_active":             @"isActive",
                                                  @"start_work":            @"startWork",
                                                  @"start_full_time_work":  @"startFullTimeWork",
                                                  @"stop_work":             @"stopWork",
                                                  @"phone":                 @"phone",
                                                  @"phone_on_desk":         @"phoneDesk",
                                                  @"skype":                 @"skype",
                                                  @"irc":                   @"irc",
                                                  @"email":                 @"email",
                                                  @"tasks_link":            @"tasksLink",
                                                  @"availability_link":     @"availabilityLink",
                                                  @"roles":                 @"roles",
                                                  @"groups":                @"groups",
                                                  }];
    
    return mapping;
}

@end