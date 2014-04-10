//
//  PGEstimationResultsViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 08/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGEstimationResultsViewController.h"
#import "PGTicketCreateViewController.h"
#import "UIViewController+PGSessionRuntime.h"
#import "PGSessionGameplayViewController.h"

@implementation PGEstimationResultsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.prompt = [NSString stringWithFormat:@"Estimated ticket: %@", [GameManager defaultManager].activeTicket.displayValue];
    
    _isEstimationFinished = NO;
    [self revalidateBarItems];
    
    [self prepareForGameSession];
    
    [self revalidateVotes];
    
    __weak typeof(self) weakSelf = self;
    
    [self addQuickObserverForNotificationWithKey:kGameManagerNotificationEstimationRoundDidStart withBlock:^(NSNotification *note) {
        [weakSelf popToViewControllerOfClass:[PGSessionGameplayViewController class]];
    }];
    
    [self addQuickObserverForNotificationWithKey:kGameManagerNotificationTicketVoteReceived withBlock:^(NSNotification *note) {
        [weakSelf revalidateVotes];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[GameManager defaultManager] joinActiveSessionWithCompletionHandler:^(GameManager *manager, NSError *error) { }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeQuickObservers];
}

#pragma mark - Bar button

- (void)revalidateBarItems
{
    if ([GameManager defaultManager].activeSession.isOwnedByCurrentUser)
    {
        if (_isEstimationFinished)
        {
            self.navigationItem.title = @"Estimation Results";
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"New" style:UIBarButtonItemStylePlain handler:^(id sender) {
                [self popToViewControllerOfClass:[PGTicketCreateViewController class]];
            }];
        }
        else
        {
            self.navigationItem.title = @"Estimation Progress";
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"Stop" style:UIBarButtonItemStylePlain handler:^(id sender) {
                [[GameManager defaultManager] stopRoundWithCompletionHandler:^(GameManager *manager, NSError *error) {
                    if (error)
                        return;
                    
                    _isEstimationFinished = YES;
                    
                    [self revalidateBarItems];
                }];
            }];
        }
    }
}

#pragma mark - Votes distribution

- (void)revalidateVotes
{
    // TODO
    NSLog(@"%@", [GameManager defaultManager].activeTicket.votesDistribution);
}

@end
