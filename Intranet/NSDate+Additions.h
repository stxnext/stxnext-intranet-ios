//
//  NSDate+Additions.h
//  Intranet
//
//  Created by Adam on 25.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Additions)

- (BOOL)compareIfEqualDay:(NSDate *)anotherDay;

- (NSDate *)dateWithHour:(NSInteger)hour
                 minute:(NSInteger)minute
                 second:(NSInteger)second;

- (NSDate *)dateWithHourMinutes;

@end
