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
    } withDisconnectHandler:^(GameManager *manager, NSError *error) {
        if (error)
        {
            [self.navigationController popViewControllerAnimated:YES];
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
