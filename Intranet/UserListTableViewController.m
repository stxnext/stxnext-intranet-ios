//
//  UserTableViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UserListTableViewController.h"

#import "APIRequest.h"
#import "AFHTTPRequestOperation+Redirect.h"
#import "UIView+Screenshot.h"
#import "AppDelegate+Settings.h"

@implementation UserListTableViewController
{
    __weak UIPopoverController *myPopover;
    
    BOOL shouldReloadAvatars;
    BOOL isUpdating;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self informStopDownloading];
    [self addRefreshControl];
    
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
                                              
                                              [[self.tabBarController.tabBar.items lastObject] setTitle:@"Me"];
                                              
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

- (void)addRefreshControl
{
    if (self.refreshControl == nil)
    {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refresh"];
        [refreshControl addTarget:self action:@selector(startRefreshData)forControlEvents:UIControlEventValueChanged];
        _refreshControl = refreshControl;
        self.refreshControl = refreshControl;
    }
}

- (void)startRefreshData
{
    [self showNoSelectionUserDetails];
    
    _showActionButton.enabled = NO;
    
    [self loadUsersFromAPI:^{
        [self stopRefreshData];
    }];
    
    shouldReloadAvatars = YES;
}

- (void)stopRefreshData
{
    [_refreshControl endRefreshing];
    
    _showActionButton.enabled = YES;
    isUpdating = NO;
}

- (void)loadUsersFromAPI:(void (^)(void))endAction
{
    if (isUpdating)
    {
        return;
    }
    
    isUpdating = YES;
    isDatabaseBusy = NO;
    
    [self showOutViewButton];
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSLog(@"No internet");

        endAction();
        
        return;
    }
    
    [self informStartDownloading];
    
    __block NSInteger operations = 2;
    __block id users;
    __block id absencesAndLates;
    
    NSLog(@"Loading from: API");

    void(^load)(void) = ^(void) {
        NSLog(@"^LOAD");
        [[NSOperationQueue new] addOperationWithBlock:^{
            isDatabaseBusy = YES;
            [self hideOutViewButton];
            
            if (shouldReloadAvatars)
            {
                avatarsToRefresh = [NSMutableArray new];
                [[UIImageView sharedCookies] removeAllObjects];
                
                NSArray *temp = [JSONSerializationHelper objectsWithClass:[RMUser class]
                                                       withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                                        ascending:YES
                                                                                                         selector:@selector(localizedCompare:)]
                                                            withPredicate:[NSPredicate predicateWithFormat:@"isActive = YES"]
                                                         inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                
                for (RMUser *user in temp)
                {
                    [avatarsToRefresh addObject:user.id];
                }
                
                shouldReloadAvatars = NO;
            }

            @synchronized(self){
                [JSONSerializationHelper deleteObjectsWithClass:[RMUser class]
                                               inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                
                [JSONSerializationHelper deleteObjectsWithClass:[RMAbsence class]
                                               inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                
                [JSONSerializationHelper deleteObjectsWithClass:[RMLate class]
                                               inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                
                for (id user in users[@"users"])
                {
                    [RMUser mapFromJSON:user];
                }
                
                for (id absence in absencesAndLates[@"absences"])
                {
                    RMAbsence *rm = (RMAbsence *)[RMAbsence mapFromJSON:absence];
                    rm.isTomorrow = [NSNumber numberWithBool:NO];
                }
                
                for (id late in absencesAndLates[@"lates"])
                {
                    RMLate *rm = (RMLate *)[RMLate mapFromJSON:late];
                    rm.isTomorrow = [NSNumber numberWithBool:NO];
                }
                
                for (id absence in absencesAndLates[@"absences_tomorrow"])
                {
                    RMAbsence *rm = (RMAbsence *)[RMAbsence mapFromJSON:absence];
                    rm.isTomorrow = [NSNumber numberWithBool:YES];
                }
                
                for (id late in absencesAndLates[@"lates_tomorrow"])
                {
                    RMLate *rm = (RMLate *)[RMLate mapFromJSON:late];
                    rm.isTomorrow = [NSNumber numberWithBool:YES];
                }

                [[DatabaseManager sharedManager] saveContext];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    @synchronized(self){
                        self.allUsers = nil;
                        self.tomorrowOutOffOfficePeople = nil;
                        self.todayOutOffOfficePeople = nil;
                        
                        [self loadUsersFromDatabase];
                        [self informStopDownloading];
                        
                        isDatabaseBusy = NO;
                        [self showOutViewButton];
                        endAction();
                    }
                }];
            }
        }];
    };
    
    [[HTTPClient sharedClient] startOperation:[RMUser userLoggedType] == UserLoginTypeTrue ? [APIRequest getUsers] : [APIRequest getFalseUsers]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          
                                          NSLog(@"Loaded: users");
                                          
                                          users = responseObject;
                                          
                                          if (--operations == 0)
                                          {
                                              NSLog(@"LOAD");
                                              load();
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          
                                          NSLog(@"Users API Loading Error");
                                          
                                          if ([operation redirectToLoginView])
                                          {
                                              [self showLoginScreen];
                                          }
                                          
                                          [self.tableView reloadData];
                                          
                                          [[HTTPClient sharedClient].operationQueue cancelAllOperations];
                                          
                                          endAction();
                                          
                                          [self informStopDownloading];
                                      }];
    
    [[HTTPClient sharedClient] startOperation:[RMUser userLoggedType] == UserLoginTypeTrue ? [APIRequest getPresence] : [APIRequest getFalsePresence]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          
                                          absencesAndLates = responseObject;
                                          
                                          NSLog(@"Loaded: absences and lates");
                                          
                                          if (--operations == 0)
                                          {
                                              NSLog(@"LOAD");
                                              load();
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          
                                          NSLog(@"Presence API Loading Error");
                                          
                                          [[HTTPClient sharedClient].operationQueue cancelAllOperations];
                                        
                                          endAction();
                                          
                                          [self informStopDownloading];
                                      }];
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

#pragma mark - Add OOO

- (void)informStartDownloading
{
    [[NSNotificationCenter defaultCenter] postNotificationName:DID_START_REFRESH_PEOPLE object:self];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_REFRESH_PEOPLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)informStopDownloading
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_REFRESH_PEOPLE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:DID_END_REFRESH_PEOPLE object:self];
}

- (void)showOutViewButton
{
    [self performBlockOnMainThread:^{
        switch (currentListState)
        {
            case ListStateAll:
                [self.viewSwitchButton setTitle:@"Out"];
                self.title = @"All";
                [self addRefreshControl];
                
                break;
                
            case ListStateOutToday:
                [self.viewSwitchButton setTitle:@"Tomorrow"];
                self.title = @"Out";
                self.refreshControl = nil;
                
                break;
                
            case ListStateOutTomorrow:
                [self.viewSwitchButton setTitle:@"All"];
                self.title = @"Tomorrow";

                break;
                
            default:break;
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
            
        case ListStateAll:
            return ListStateOutToday;
            
        case ListStateOutToday:
            return ListStateOutTomorrow;
            
        case ListStateOutTomorrow:
            return ListStateAll;
    }
    
    return ListStateAll;
}

@end
