//
//  NSDate+TimePeriods.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 23.11.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import "NSDate+TimePeriods.h"

@implementation NSDate (TimePeriods)

+ (NSDate *)firstDayOfCurrentMonth {
    NSDate *monthStart;
    [[NSCalendar currentCalendar] rangeOfUnit: NSCalendarUnitMonth
                                    startDate: &monthStart
                                     interval: nil
                                      forDate: [self localDateFromDate:[NSDate date]]];
    
    return [self localDateFromDate:monthStart];
}

+ (NSDate *)firstDayOfCurrentQuarter {
    NSDate *quarterStart;
    [[NSCalendar currentCalendar] rangeOfUnit: NSCalendarUnitQuarter
                                    startDate: &quarterStart
                                     interval: nil
                                      forDate: [self localDateFromDate:[NSDate date]]];
    
    return [self localDateFromDate:quarterStart];
}

+ (NSDate *)lastDayOfCurrentMonth {
    NSDateComponents* components = [[self calendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[self firstDayOfCurrentMonth]];
    [components setMonth:[components month] + 1];
    [components setDay:0];
    
    return [self localDateFromDate:[[self calendar] dateFromComponents:components]];
}

+ (NSDate *)lastDayOfCurrentQuarter {
    NSDateComponents* components = [[self calendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[self localDateFromDate:[NSDate date]]];
    NSUInteger quarter = ([components month] - 1) / 3 + 1;
    NSUInteger lastQuarterMonth = quarter * 3;
    NSUInteger nextQuarterFirstMonth = lastQuarterMonth + 1;
    [components setMonth: nextQuarterFirstMonth];
    [components setDay: 0];
    
    return [self localDateFromDate:[[NSCalendar currentCalendar] dateFromComponents: components]];
}

+ (NSDate *)localDateFromDate:(NSDate *)date
{
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    NSInteger interval = [timeZone secondsFromGMTForDate:date];
    return [NSDate dateWithTimeInterval:interval sinceDate:date];
}

+ (NSCalendar *)calendar {
    return [NSCalendar currentCalendar];
}

@end
