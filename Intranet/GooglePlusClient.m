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
    
    // Send sign in request
    if ([self.signIn hasAuthInKeychain])
    {
        [self.signIn trySilentAuthentication];
    }
    else
    {
        [self.signIn authenticate];
    }
}

#pragma mark Private methods

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _completionBlock = nil;
        _signIn = nil;
    }
    
    return self;
}

- (GPPSignIn*)signIn
{
    if (_signIn)
        return _signIn;
    
    // Setup sign in request
    _signIn = [GPPSignIn sharedInstance];
    
    _signIn.clientID = [[NSBundle mainBundle] infoDictionary][@"CCGooglePlusClientID"];
    
    _signIn.scopes = @[ kGTLAuthScopePlusUserEmail,
                       kGTLAuthScopePlusUserProfile,
                       kGTLAuthScopePlusCalendar,
                       kGTLAuthScopePlusCalendarReadonly ];
    
    _signIn.delegate = self;
    
    return _signIn;
}

#pragma mark Google Plus sign in delegate

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    // Perform completion block
    if (_completionBlock)
        _completionBlock(auth, error);
}

@end
