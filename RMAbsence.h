//
//  RMAbsence.h
//  Intranet
//
//  Created by Adam on 27.11.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RMUser;

@interface RMAbsence : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * remarks;
@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSDate * stop;
@property (nonatomic, retain) NSNumber * isTomorrow;
@property (nonatomic, retain) RMUser *user;

@end
