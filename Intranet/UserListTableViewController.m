//
//  UserTableViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UserListTableViewController.h"

#import "UIView+Screenshot.h"

@implementation UserListTableViewController
{
    __weak UIPopoverController *myPopover;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //update data
    if ([RMUser userLoggedType] != UserLoginTypeNO)
    {
        [self loadUsersFromDatabase];

        [self performBlockInCurrentThread:^{
            [self loadUsersFromAPI:^{
                [self stopRefreshData];
            }];
        } afterDelay:1];
    }
    
    if ([RMUser userLoggedType] == UserLoginTypeFalse || [RMUser userLoggedType] == UserLoginTypeError)
    {
        [[self.tabBarController.tabBar.items lastObject] setTitle:@"About"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([RMUser userLoggedType] == UserLoginTypeNO)
    {
        [self showLoginScreen];
    }
}

#pragma mark - Login

- (void)showLoginScreen
{
    [self showNoSelectionUserDetails];
    
    [LoginViewController presentAfterSetupWithDecorator:^(UIModalViewController *controller) {
        LoginViewController *customController = (LoginViewController*)controller;
        customController.delegate = self;
    }];
}

- (void)finishedLoginWithCode:(NSString *)code withError:(NSError *)error
{
    // Assume success, use code to fetch cookies
    [[HTTPClient sharedClient] startOperation:[APIRequest loginWithCode:code]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          // We expect 302
                                          [RMUser setUserLoggedType:UserLoginTypeError];
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          
                                          NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:operation.response.allHeaderFields
                                                                                                    forURL:operation.response.URL];
                                          
                                          [[HTTPClient sharedClient] saveCookies:cookies];
                                          
                                          // If redirected properly
                                          if (operation.response.statusCode == 302 && cookies)
                                          {
                                              [RMUser setUserLoggedType:UserLoginTypeTrue];
                                                                                            
                                              [self loadUsersFromAPI:^{
                                                  [self stopRefreshData];
                                              }];
                                          }
                                          else
                                          {
                                              //error RMUser login (e.g. account not exists)
                                              [RMUser setUserLoggedType:UserLoginTypeFalse];
                                              
                                              [[self.tabBarController.tabBar.items lastObject] setTitle:@"About"];
                                              
                                              [self loadUsersFromAPI:^{
                                                  [self stopRefreshData];
                                              }];
                                          }
                                      }];
}

#pragma mark - Download data

- (void)startRefreshData
{
    [self showNoSelectionUserDetails];
    
    self.showActionButton.enabled = NO;
    
    if (currentListState == ListStateAll)
    {
        [self loadUsersFromAPI:^{
            [self stopRefreshData];
        }];
    }
    else
    {
        [self reloadLates:^{
            [self stopRefreshData];
        }];
    }

    shouldReloadAvatars = YES;
}

- (void)closePopover
{
    if (myPopover)
    {
        [myPopover dismissPopoverAnimated:YES];
    }
}

#pragma mark - Storyboard

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (myPopover)
    {
        [myPopover dismissPopoverAnimated:YES];
        
        return NO;
    }
    else
    {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

- (void)showOutViewButton
{
    [self performBlockOnMainThread:^{
        switch (currentListState)
        {
            case ListStateAll:
                [self.viewSwitchButton setTitle:@"Out"];
                self.title = NSLocalizedString(@"Employees", nil);
                break;
                
            case ListStateAbsent:
            case ListStateWorkFromHome:
            case ListStateOutOfOffice:
                [self.viewSwitchButton setTitle:@"Absences"];
                self.title = NSLocalizedString(@"Absences", nil);
                break;

            default:
                break;
        }
        
        self.viewSwitchButton.enabled = YES;
        [self.navigationItem setLeftBarButtonItem:self.viewSwitchButton animated:YES];
    } afterDelay:0];
}

- (ListState)nextListState
{
    switch (currentListState)
    {
        case ListStateNotSet:
            return ListStateAll;
        
        default: break;
    }
    
    return ListStateAll;
}

@end
