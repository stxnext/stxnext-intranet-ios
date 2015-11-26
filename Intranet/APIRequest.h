//
//  APIRequest.h
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIRequest : NSObject

+ (AFHTTPRequestOperation *)loginWithCode:(NSString *)code;
+ (AFHTTPRequestOperation *)getUsers;
+ (AFHTTPRequestOperation *)getFalseUsers;
+ (AFHTTPRequestOperation *)getPresence;
+ (AFHTTPRequestOperation *)getFalsePresence;
+ (AFHTTPRequestOperation *)logout;
+ (AFHTTPRequestOperation *)user;
+ (AFHTTPRequestOperation *)currentUser;

+ (AFHTTPRequestOperation *)addHours:(NSDictionary *)parameters;
+ (AFHTTPRequestOperation *)sendAbsence:(NSDictionary *)parameters;
+ (AFHTTPRequestOperation *)sendLateness:(NSDictionary *)parameters;
+ (AFHTTPRequestOperation *)getFreeDays;
+ (AFHTTPRequestOperation *)getUserHoursForMonthInDate:(NSDate *)date;
+ (AFHTTPRequestOperation *)getUserTimesFromDate:(NSDate *)startDate toDate:(NSDate *)endDate;
+ (AFHTTPRequestOperation *)getWorkedHoursForUser:(NSNumber *)userId;
+ (AFHTTPRequestOperation *)getProjectsList;
@end
