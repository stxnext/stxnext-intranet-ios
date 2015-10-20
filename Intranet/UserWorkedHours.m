//
//  UserWorkedHours.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 20.10.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import "UserWorkedHours.h"

#define kPERIOD_TODAY   @"today"
#define kPERIOD_MONTH   @"month"
#define kPERIOD_QUARTER @"quarter"

#define kVALUE_ARRIVAL  @"arrival"
#define kVALUE_DIFF     @"diff"
#define kVALUE_SUM      @"sum"
#define kVALUE_REMAIN   @"remaining"
#define kVALUE_PRESENT  @"present"

@interface UserWorkedHours()

@property (nonatomic) NSNumber *todayArrival;
@property (nonatomic) NSNumber *todayDiff;
@property (nonatomic) NSNumber *todaySum;
@property (nonatomic) NSNumber *todayRemaining;
@property (nonatomic) NSNumber *todayPresent;

@property (nonatomic) NSNumber *monthDiff;
@property (nonatomic) NSNumber *monthSum;

@property (nonatomic) NSNumber *quarterDiff;
@property (nonatomic) NSNumber *quarterSum;

@property (nonatomic) BOOL hasHours;

@end

@implementation UserWorkedHours

+ (id)sharedHours {
    static UserWorkedHours *myHours = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myHours = [[self alloc] init];
    });
    myHours.hasHours = NO;
    return myHours;
}

- (void)setHoursFromDictionary:(NSDictionary *)workedHours {
    self.todayArrival = [[workedHours objectForKey:kPERIOD_TODAY] objectForKey:kVALUE_ARRIVAL];
    self.todayDiff = [[workedHours objectForKey:kPERIOD_TODAY] objectForKey:kVALUE_DIFF];
    self.todaySum = [[workedHours objectForKey:kPERIOD_TODAY] objectForKey:kVALUE_SUM];
    self.todayRemaining = [[workedHours objectForKey:kPERIOD_TODAY] objectForKey:kVALUE_REMAIN];
    self.todayPresent = [[workedHours objectForKey:kPERIOD_TODAY] objectForKey:kVALUE_PRESENT];
    
    self.monthDiff = [[workedHours objectForKey:kPERIOD_MONTH] objectForKey:kVALUE_DIFF];
    self.monthSum = [[workedHours objectForKey:kPERIOD_MONTH] objectForKey:kVALUE_SUM];
    
    self.quarterDiff = [[workedHours objectForKey:kPERIOD_QUARTER] objectForKey:kVALUE_DIFF];
    self.quarterSum = [[workedHours objectForKey:kPERIOD_QUARTER] objectForKey:kVALUE_SUM];
    
    self.hasHours = YES;
}

- (BOOL)hasHours {
    return self.hasHours;
}

- (NSNumber *)getTodaysArrival {
    return self.todayArrival;
}
- (NSNumber *)getTodaysDiff {
    return self.todayDiff;
}
- (NSNumber *)getTodaysSum {
    return self.todaySum;
}
- (NSNumber *)getTodaysRemaining {
    return self.todayRemaining;
}
- (NSNumber *)getTodaysPresent {
    return self.todayPresent;
}

- (NSNumber *)getMonthDiff {
    return self.monthDiff;
}
- (NSNumber *)getMonthSum {
    return self.monthSum;
}

- (NSNumber *)getQuarterDiff {
    return self.quarterDiff;
}
- (NSNumber *)getQuarterSum {
    return self.quarterSum;
}

@end
