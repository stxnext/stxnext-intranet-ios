//
//  UIViewController+PGSessionRuntime.m
//  Intranet
//
//  Created by Dawid Żakowski on 09/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "UIViewController+PGSessionRuntime.h"
#import "PGSessionLobbyViewController.h"
#import "PGSessionListViewController.h"

@implementation UIViewController (PGSessionRuntime)

- (BOOL)popToViewControllerOfClass:(Class)class
{
    UIViewController* viewController = [self.navigationController.viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class = %@", class]].firstObject;
    
    if (!viewController)
        return NO;
    
    [self.navigationController popToViewController:viewController animated:YES];
    return YES;
}

- (void)prepareForGameSession
{
    // Notifications handler
    __weak typeof(self) weakSelf = self;
    
    [self addQuickObserverForNotificationWithKey:kGameManagerNotificationSessionDidClose
                                       withBlock:^(NSNotification *note) {
                                           [weakSelf popToViewControllerOfClass:[PGSessionListViewController class]];
                                           
                                           [UIAlertView showWithTitle:@"Session closed" message:@"Session owner has closed the poker session." handler:nil];
                                       }];
    
    [self addQuickObserverForNotificationWithKey:kGameManagerNotificationSessionDidDisconnect
                                       withBlock:^(NSNotification *note) {
                                           NSError* error = note.object;
                                           
                                           [weakSelf popToViewControllerOfClass:[PGSessionLobbyViewController class]];
                                           
                                           if (error)
                                           {
                                               [UIAlertView showWithTitle:@"Server problem" message:@"Connection to game server was lost. Please try again." handler:nil];
                                               return;
                                           }
                                       }];
    
    [self addQuickObserverForNotificationWithKey:kGameManagerNotificationSessionPeopleDidChange
                                       withBlock:^(NSNotification *note) {
                                           NSArray* users = note.object;
                                           
                                           GMUser* updatedOwner = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self = %@", [GameManager defaultManager].activeSession.owner]].firstObject;
                                           
                                           if (updatedOwner && !updatedOwner.active)
                                           {
                                               [[GameManager defaultManager] leaveActiveSession];
                                               [UIAlertView showWithTitle:@"Session problem" message:@"Session owner has left the game." handler:nil];
                                           }
                                       }];
    
    // Right bar button update
    if ([GameManager defaultManager].activeSession.isOwnedByCurrentUser)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemAction handler:^(id sender) {
            NSString* title = [NSString stringWithFormat:@"Poker Session: %@", [GameManager defaultManager].activeSession.name];
            
            UIActionSheet* actionSheet = [UIActionSheet bk_actionSheetWithTitle:title];
            
            [actionSheet bk_addButtonWithTitle:@"Show participants list" handler:^{
                [self showParticipants:sender];
            }];
            
            [actionSheet bk_addButtonWithTitle:@"Leave poker session" handler:^{
                [self leaveSession];
            }];
            
            [actionSheet bk_addButtonWithTitle:@"Finish poker session" handler:^{
                [UIAlertView showConfirmationDialogWithTitle:@"Poker Session" message:@"Are you sure you want to finish this poker session?" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1)
                    {
                        [[GameManager defaultManager] finishActiveSessionWithCompletionHandler:^(GameManager *manager, NSError *error) { }];
                        [self popToViewControllerOfClass:[PGSessionListViewController class]];
                    }
                }];
            }];
            
            [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
            
            [actionSheet showFromBarButtonItem:sender animated:YES];
        }];
    }
    else
    {
        UIImage* image = [UIImage imageNamed:@"tabbar_icon_users"];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Leave" style:UIBarButtonItemStylePlain target:self action:@selector(leaveSession)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(showParticipants:)];
    }
}

- (void)leaveSession
{
    [UIAlertView showConfirmationDialogWithTitle:@"Poker Session" message:@"Are you sure you want to leave this poker session?" handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1)
        {
            [[GameManager defaultManager] leaveActiveSession];
        }
    }];
}

- (IBAction)showParticipants:(id)sender
{
    [self performSegueWithIdentifier:@"ShowSessionPeopleSegue" sender:sender];
}

- (void)dismissParticipants
{
    [self.sideMenuViewController hideMenuViewController];
}

@end
