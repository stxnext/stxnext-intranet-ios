//
//  FirstViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "FirstViewController.h"
#import "GooglePlusClient.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[GooglePlusClient singleton] authenticateWithCompletionBlock:^(GTMOAuth2Authentication *auth, NSError *error) {
        NSLog(@"auth: %@, error: %@", auth, error);
    }];
}

@end
