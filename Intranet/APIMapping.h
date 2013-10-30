//
//  APIMapping.h
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIMapping : NSObject

+ (NSDictionary*)mapping;
+ (NSDictionary*)inverseMapping;
+ (APIMapping*)mapFromJSON:(NSDictionary*)json;
- (NSDictionary*)mapToJSON:(NSDictionary*)json;

@end

@interface RMUser : APIMapping

@property (nonatomic, strong) NSNumber* id;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* imageURL;
@property (nonatomic, strong) NSString* avatarURL;
@property (nonatomic, strong) NSString* location;
@property (nonatomic, strong) NSNumber* isFreelancer;
@property (nonatomic, strong) NSNumber* isClient;
@property (nonatomic, strong) NSNumber* isActive;
@property (nonatomic, strong) NSDate* startWork;
@property (nonatomic, strong) NSDate* startFullTimeWork;
@property (nonatomic, strong) NSDate* stopWork;
@property (nonatomic, strong) NSString* phone;
@property (nonatomic, strong) NSString* phoneDesk;
@property (nonatomic, strong) NSString* skype;
@property (nonatomic, strong) NSString* irc;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* tasksLink;
@property (nonatomic, strong) NSString* availabilityLink;
@property (nonatomic, strong) NSArray* roles;
@property (nonatomic, strong) NSArray* groups;

@end