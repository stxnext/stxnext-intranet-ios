//
//  RMTeam.h
//  Intranet
//
//  Created by Adam on 14.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RMUser;

@interface RMTeam : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *users;
@end

@interface RMTeam (CoreDataGeneratedAccessors)

- (void)addUsersObject:(RMUser *)value;
- (void)removeUsersObject:(RMUser *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;

@end
