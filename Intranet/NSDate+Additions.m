//
//  NSDate+Additions.m
//  Intranet
//
//  Created by Adam on 25.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

- (BOOL)compareIfEqualDay:(NSDate *)anotherDay
{
    NSDateComponents *compSelf  = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:self];
    NSDateComponents *compSecond  = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:anotherDay];
    
    if ([compSelf day] == [compSecond day] && [compSelf month] == [compSecond month] && [compSelf year] == [compSecond year]) {
        return YES;
    }
    return NO;
}

- (NSDate *)dateWithHour:(NSInteger)hour
                  minute:(NSInteger)minute
                  second:(NSInteger)second
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:self];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:second];
    
    NSDate *newDate = [calendar dateFromComponents:components];
    
    return newDate;
}

- (NSDate *)dateWithHourMinutes
{
    unsigned int flags = NSCalendarUnitHour | NSCalendarUnitDay;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:self];
    //Taking the time zone into account
    NSDate *hourOnly = [calendar dateFromComponents:components];
    
    return hourOnly;
}

@end
