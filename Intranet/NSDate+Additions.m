//
//  NSDate+Additions.m
//  Intranet
//
//  Created by Adam on 25.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (NSDate *)dateWithHour:(NSInteger)hour
                  minute:(NSInteger)minute
                  second:(NSInteger)second
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
                                               fromDate:self];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];
    
    NSDate *newDate = [calendar dateFromComponents:components];
    
    return newDate;
}

@end
