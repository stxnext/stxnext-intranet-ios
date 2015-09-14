//
//  RMUser.h
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RMAbsence, RMLate;

@interface RMUser : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * avatarURL;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * isFreelancer;
@property (nonatomic, retain) NSNumber * isClient;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSDate * startWork;
@property (nonatomic, retain) NSDate * startFullTimeWork;
@property (nonatomic, retain) NSDate * stopWork;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * phoneDesk;
@property (nonatomic, retain) NSString * skype;
@property (nonatomic, retain) NSString * irc;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * tasksLink;
@property (nonatomic, retain) NSString * availabilityLink;
@property (nonatomic, retain) id roles;
@property (nonatomic, retain) id groups;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSSet *absences;
@property (nonatomic, retain) NSSet *lates;

@end

@interface RMUser (CoreDataGeneratedAccessors)

- (void)addAbsencesObject:(RMAbsence *)value;
- (void)removeAbsencesObject:(RMAbsence *)value;
- (void)addAbsences:(NSSet *)values;
- (void)removeAbsences:(NSSet *)values;

- (void)addLatesObject:(RMLate *)value;
- (void)removeLatesObject:(RMLate *)value;
- (void)addLates:(NSSet *)values;
- (void)removeLates:(NSSet *)values;

@end
