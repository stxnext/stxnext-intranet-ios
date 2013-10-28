//
//  GooglePlusClient.m
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "GooglePlusClient.h"

@implementation GooglePlusClient

#pragma mark Public methods

static GooglePlusClient* _singleton = nil;

+ (GooglePlusClient*)singleton
{
    return _singleton ?: (_singleton = [GooglePlusClient new]);
}

- (void)authenticateWithCompletionBlock:(void (^)(GTMOAuth2Authentication* auth, NSError* error))completionBlock
{
    // Retain completion block
    _completionBlock = completionBlock;
    
    // Setup sign in request
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    
    signIn.clientID = [[NSBundle mainBundle] infoDictionary][@"CCGooglePlusClientID"];
    
    signIn.scopes = @[ kGTLAuthScopePlusUserEmail,
                       kGTLAuthScopePlusUserProfile,
                       kGTLAuthScopePlusCalendar,
                       kGTLAuthScopePlusCalendarReadonly ];
    
    signIn.delegate = self;
    
    // Send sign in request
    if ([signIn hasAuthInKeychain])
        [signIn trySilentAuthentication];
    else
        [signIn authenticate];
}

#pragma mark Google Plus sign in delegate

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    // Perform completion block
    if (_completionBlock)
        _completionBlock(auth, error);
}

@end
