//
//  PGSessionGameplayViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 02/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGSessionGameplayViewController.h"

@implementation PGSessionGameplayViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GameManager defaultManager] joinActiveSessionWithCompletionHandler:^(GameManager *manager, NSError *error) {
        if (error)
            return;
        
        self.navigationItem.prompt = manager.listener.localAddress;
        
        [[GameManager defaultManager] fetchActiveSessionUsersWithCompletionHandler:^(GameManager *manager, NSError *error) {
            if (error)
            {
                [[GameManager defaultManager] leaveActiveSession];
                
                [UIAlertView showWithTitle:@"Server problem" message:@"Could not load poker session from game server." handler:nil];
                return;
            }
            
            // Done here
        }];
    } withDisconnectHandler:^(GameManager *manager, NSError *error) {
        if (![self isMovingFromParentViewController])
            [self.navigationController popViewControllerAnimated:YES];
        
        if (error)
        {
            [UIAlertView showWithTitle:@"Server problem" message:@"Connection to server was lost. Please try again." handler:nil];
            return;
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[GameManager defaultManager] leaveActiveSession];
}

@end
