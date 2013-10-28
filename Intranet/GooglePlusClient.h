//
//  GooglePlusClient.h
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GooglePlusClient : NSObject<GPPSignInDelegate>
{
    void (^_completionBlock)(GTMOAuth2Authentication* auth, NSError* error);
}

+ (GooglePlusClient*)singleton;
- (void)authenticateWithCompletionBlock:(void (^)(GTMOAuth2Authentication* auth, NSError* error))completionBlock;

@end
