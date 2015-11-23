//
//  NSDate+TimePeriods.h
//  Intranet
//
//  Created by Paweł Urbanowicz on 23.11.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TimePeriods)

+ (NSDate *)firstDayOfCurrentQuarter;
+ (NSDate *)firstDayOfCurrentMonth;
+ (NSDate *)lastDayOfCurrentQuarter;
+ (NSDate *)lastDayOfCurrentMonth;

@end
