//
//  RMAbsence.h
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RMUser;

@interface RMAbsence : NSManagedObject

@property (nonatomic, retain) NSDate * start;
@property (nonatomic, retain) NSDate * stop;
@property (nonatomic, retain) NSString * remarks;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) RMUser *user;

@end
