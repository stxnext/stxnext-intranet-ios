//
//  UserWorkedHours.h
//  Intranet
//
//  Created by Paweł Urbanowicz on 20.10.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserWorkedHours : NSObject

+ (id)sharedHours;
- (void)setHoursFromDictionary:(NSDictionary *)workedHours;

- (NSNumber *)getTodaysArrival;
- (NSNumber *)getTodaysDiff;
- (NSNumber *)getTodaysSum;
- (NSNumber *)getTodaysRemaining;
- (NSNumber *)getTodaysPresent;

- (NSNumber *)getMonthDiff;
- (NSNumber *)getMonthSum;

- (NSNumber *)getQuarterDiff;
- (NSNumber *)getQuarterSum;
- (BOOL)hasHours;

@end
