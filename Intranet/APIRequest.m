//
//  APIRequest.m
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "APIRequest.h"
#import "HTTPClient.h"
#import "AFHTTPRequestOperation+Redirect.h"

@implementation APIRequest

+ (AFHTTPRequestOperation *)loginWithCode:(NSString *)code
{
    AFHTTPRequestOperation *request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodHEAD
                                                                                     action:[NSString stringWithFormat:@"auth/callback?code=%@", code]
                                                                                 parameters:nil];
    
    [request blockRedirections];
    
    return request;
}

+ (AFHTTPRequestOperation *)getUsers
{
    AFHTTPRequestOperation *request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodGET
                                                                                     action:@"api/users?full=1&inactive=1"
                                                                                 parameters:nil];
    
    [request blockRedirections];
    
    return request;
}

+ (AFHTTPRequestOperation *)getFalseUsers
{
    AFHTTPRequestOperation *request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodGET
                                                                                     action:@"mobile.app/users.json"
                                                                                 parameters:nil];
    
    return request;
}

+ (AFHTTPRequestOperation *)getPresence
{
    AFHTTPRequestOperation *request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodGET
                                                                                     action:@"api/presence"
                                                                                 parameters:nil];
    
    return request;
}

+ (AFHTTPRequestOperation *)getFalsePresence
{
    AFHTTPRequestOperation *request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodGET
                                                                                     action:@"mobile.app/presence.json"
                                                                                 parameters:nil];
    
    return request;
}

+ (AFHTTPRequestOperation *)logout
{
    AFHTTPRequestOperation *request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodHEAD
                                                                                     action:@"auth/logout"
                                                                                 parameters:nil];
    [request blockRedirections];
    
    return request;
}

+ (AFHTTPRequestOperation *)currentUser
{
    AFHTTPRequestOperation *request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodGET
                                                                                     action:@"api/current_user"
                                                                                 parameters:nil];
    
    return request;
}

+ (AFHTTPRequestOperation *)user
{
    AFHTTPRequestOperation *request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodGET
                                                                                     action:@"user/edit"
                                                                                 parameters:nil];
    [request blockRedirections];
    
    return request;
}

+ (AFHTTPRequestOperation *)sendAbsence:(NSDictionary *)parameters
{
    AFHTTPRequestOperation *request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodPOST
                                                                                     action:@"api/absence"
                                                                                 parameters:parameters];

    NSLog(@"[REQUEST URL]\n%@\n", [request.request.URL description]);
    NSLog(@"[RESPONSE HEADERS]\n%@\n", [[request.request allHTTPHeaderFields] descriptionInStringsFileFormat]);
    NSLog(@"[RESPONSE HTTP METHOD]\n%@\n", [request.request HTTPMethod]);
    NSLog(@"[RESPONSE HTTP BODY]\n%@\n",[[NSString alloc] initWithData:request.request.HTTPBody encoding:NSUTF8StringEncoding]);

    [request blockRedirections];
    
    return request;
}

+ (AFHTTPRequestOperation *)sendLateness:(NSDictionary *)parameters
{
    AFHTTPRequestOperation *request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodPOST
                                                                                     action:@"api/lateness"
                                                                                 parameters:parameters];
    
    NSLog(@"[REQUEST URL]\n%@\n", [request.request.URL description]);
    NSLog(@"[RESPONSE HEADERS]\n%@\n", [[request.request allHTTPHeaderFields] descriptionInStringsFileFormat]);
    NSLog(@"[RESPONSE HTTP METHOD]\n%@\n", [request.request HTTPMethod]);
    NSLog(@"[RESPONSE HTTP BODY]\n%@\n",[[NSString alloc] initWithData:request.request.HTTPBody encoding:NSUTF8StringEncoding]);

    [request blockRedirections];
    
    return request;
}

+ (AFHTTPRequestOperation *)getFreeDays
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    dateFormater.dateFormat = @"dd/MM/yyyy";
    
    AFHTTPRequestOperation *request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodGET
                                                                                     action:[NSString stringWithFormat:@"api/absence_days?date_start=%@&type=planowany", [dateFormater stringFromDate:[NSDate date]] ]
                                                                                 parameters:nil];
    
    [request blockRedirections];
    
    return request;
}

+ (AFHTTPRequestOperation *)getWorkedHoursForUser:(NSNumber *)userId
{
    AFHTTPRequestOperation *request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodGET action:[NSString stringWithFormat:@"api/worked_hours?user_id=%@", userId] parameters:nil];
    
    [request blockRedirections];
    return request;
}

@end
