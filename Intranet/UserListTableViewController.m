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
#import "PlaningPokerViewController.h"
#import "UIView+Screenshot.h"
#import "AppDelegate+Settings.h"


static CGFloat statusBarHeight;
static CGFloat navBarHeight;
static CGFloat tabBarHeight;


@implementation UserListTableViewController
{
    __weak UIPopoverController *myPopover;
    BOOL canShowNoResultsMessage;
    
    NSString *searchedString;
    NSIndexPath *currentIndexPath;
    NSMutableArray *avatarsToRefresh;
    BOOL shouldReloadAvatars;
    ListState currentListState;
    BOOL isDatabaseBusy;
    BOOL isUpdating;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self informStopDownloading];
    
    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    navBarHeight = self.navigationController.navigationBar.frame.size.height;
    tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    searchedString = @"";
    _actionSheet = nil;
    _userList = [NSMutableArray array];
    
    [self addRefreshControl];
    
    [self.tableView hideEmptySeparators];
    [self.searchDisplayController.searchResultsTableView hideEmptySeparators];
    
    currentListState = ListStateAll;
    [self showOutViewButton];
    
    //update data
    if ([APP_DELEGATE userLoggedType] != UserLoginTypeNO)
    {
        [self loadUsersFromDatabase];

        [self performBlockInCurrentThread:^{
            [self loadUsersFromAPI:^{
                [self stopRefreshData];
            }];
        } afterDelay:1];
    }
    
    if ([APP_DELEGATE userLoggedType] == UserLoginTypeFalse || [APP_DELEGATE userLoggedType] == UserLoginTypeError)
    {
        [[self.tabBarController.tabBar.items lastObject] setTitle:@"About"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (currentIndexPath)
    {
        [self.tableView deselectRowAtIndexPath:currentIndexPath animated:YES];
        currentIndexPath = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([APP_DELEGATE userLoggedType] == UserLoginTypeNO)
    {
        [self showLoginScreen];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    navBarHeight = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? 44.0f : 32.0f;
}

- (IBAction)changeView:(id)sender
{
    currentListState = [self nextListState];
    [self showOutViewButton];
    
    [self loadUsersFromDatabase];
}
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

#pragma mark Login delegate

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
                                          [APP_DELEGATE setUserLoggedType:UserLoginTypeError];
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          
                                          NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:operation.response.allHeaderFields
                                                                                                    forURL:operation.response.URL];
                                          
                                          [[HTTPClient sharedClient] saveCookies:cookies];
                                          
                                          // If redirected properly
                                          if (operation.response.statusCode == 302 && cookies)
                                          {
                                              [APP_DELEGATE setUserLoggedType:UserLoginTypeTrue];
                                              
                                              [[self.tabBarController.tabBar.items lastObject] setTitle:@"Me"];
                                              
                                              [self loadUsersFromAPI:^{
                                                  [self stopRefreshData];
                                              }];
                                          }
                                          else
                                          {
                                              //error with login (e.g. account not exists)
                                              [APP_DELEGATE setUserLoggedType:UserLoginTypeFalse];
                                              
                                              [[self.tabBarController.tabBar.items lastObject] setTitle:@"About"];
                                              
                                              [self loadUsersFromAPI:^{
                                                  [self stopRefreshData];
                                              }];
                                          }
                                      }];
}

- (void)startRefreshData
{
    [self showNoSelectionUserDetails];
    
    _showActionButton.enabled = NO;
    _showPlanningPokerButton.enabled = NO;
    
    [self loadUsersFromAPI:^{
        [self stopRefreshData];
    }];
    
    shouldReloadAvatars = YES;
}

- (void)stopRefreshData
{
    [_refreshControl endRefreshing];
    
    _showActionButton.enabled = YES;
    _showPlanningPokerButton.enabled = YES;
    isUpdating = NO;
}

#pragma mark - LoadUsers

- (void)loadUsersFromDatabase
{
    switch (currentListState)
    {
        case ListStateAll:
        {
            if (self.allUsers.count == 0)
            {
                self.allUsers = [JSONSerializationHelper objectsWithClass:[RMUser class]
                                                    withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                                     ascending:YES
                                                                                                      selector:@selector(localizedCompare:)]
                                                         withPredicate:[NSPredicate predicateWithFormat:@"isActive = YES AND isClient = NO AND isFreelancer = NO"]
                                                      inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
            }
            
            if (searchedString.length > 0)
            {
                _userList = [NSMutableArray arrayWithArray:[self.allUsers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
            }
            else
            {
                _userList = [NSMutableArray arrayWithArray:self.allUsers];
            }
        }
            break;
        case ListStateOutToday:
        {
            if (self.todayOutOffOfficePeople.count == 0)
            {
                self.todayOutOffOfficePeople = [RMUser loadTodayOutOffOfficePeople];
            }
            
            if (searchedString.length > 0)
            {
                _userList = [NSMutableArray arrayWithCapacity:3];
                _userList[0] = [NSMutableArray arrayWithArray:[self.todayOutOffOfficePeople[0] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
                _userList[1] = [NSMutableArray arrayWithArray:[self.todayOutOffOfficePeople[1] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
                _userList[2] = [NSMutableArray arrayWithArray:[self.todayOutOffOfficePeople[2] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
            }
            else
            {
                _userList = [NSMutableArray arrayWithArray:self.todayOutOffOfficePeople];
            }
        }
            break;
            
        case ListStateOutTomorrow:
        {
            if (self.tomorrowOutOffOfficePeople.count == 0)
            {
                self.tomorrowOutOffOfficePeople = [RMUser loadTomorrowOutOffOfficePeople];
            }
            
            if (searchedString.length > 0)
            {
                _userList = [NSMutableArray arrayWithCapacity:3];
                _userList[0] = [NSMutableArray arrayWithArray:[self.tomorrowOutOffOfficePeople filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
                _userList[1] = [NSMutableArray arrayWithArray:[self.tomorrowOutOffOfficePeople filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
                _userList[2] = [NSMutableArray arrayWithArray:[self.tomorrowOutOffOfficePeople filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
            }
            else
            {
                _userList = [NSMutableArray arrayWithArray:self.tomorrowOutOffOfficePeople];
            }
    
        }
            break;
            
        default:
            break;
    }
    
    if (searchedString.length > 0)
    {
        [self.searchDisplayController.searchResultsTableView reloadDataAnimated:YES];
    }
    else
    {
        [self.tableView reloadDataAnimated:YES];
    }
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
    
    [[HTTPClient sharedClient] startOperation:[APP_DELEGATE userLoggedType] == UserLoginTypeTrue ? [APIRequest getUsers] : [APIRequest getFalseUsers]
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
                                          
                                          [self.tableView reloadDataAnimated:YES];
                                          
                                          [[HTTPClient sharedClient].operationQueue cancelAllOperations];
                                          
                                          endAction();
                                          
                                          [self informStopDownloading];
                                      }];
    
    [[HTTPClient sharedClient] startOperation:[APP_DELEGATE userLoggedType] == UserLoginTypeTrue ? [APIRequest getPresence] : [APIRequest getFalsePresence]
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

//#pragma mark - Filter delegate
//
//- (void)changeFilterSelections:(NSArray *)filterSelection
//{
//    canShowNoResultsMessage = YES;
//    
//    [self showNoSelectionUserDetails];
//    
//    [self loadUsersFromDatabase];
//    
//    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
//}

- (void)closePopover
{
    if (myPopover)
    {
        [myPopover dismissPopoverAnimated:YES];
    }
}

#pragma mark - Search management

- (void)reloadSearchWithText:(NSString *)text
{
    canShowNoResultsMessage = NO;
    [self showNoSelectionUserDetails];
    searchedString = text;
    
    [self loadUsersFromDatabase];
}

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self reloadSearchWithText:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self reloadSearchWithText:@""];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (currentListState == ListStateAll)
    {
        return 1;
    }
    else
    {
        return [_userList count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number;
    
    if (currentListState == ListStateAll)
    {
        number = _userList.count;
    }
    else
    {
        number = [_userList[section] count];
    }
    
    if (number == 0 && canShowNoResultsMessage)
    {
        [UIAlertView showWithTitle:@"Info"
                           message:@"Nothing to show."
                             style:UIAlertViewStyleDefault
                 cancelButtonTitle:nil
                 otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                     canShowNoResultsMessage = NO;
                     [self performBlockOnMainThread:^{
                         [self loadUsersFromDatabase];
                     } afterDelay:0.75];
                 }];
    }
    
    if (number)
    {
        canShowNoResultsMessage = NO;
    }
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserCell";
    
    UserListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RMUser *user;
    
    if (currentListState == ListStateAll)
    {
        user = _userList[indexPath.row];
    }
    else
    {
        user = _userList[indexPath.section][indexPath.row];
    }

    cell.userName.text = user.name;
    
    [cell.userImage makeRadius:5 borderWidth:1 color:[UIColor grayColor]];
    
    if (!isDatabaseBusy)
    {
        cell.clockView.hidden = cell.warningDateLabel.hidden = ((user.lates.count + user.absences.count) == 0);
        
        NSDateFormatter *absenceDateFormater = [[NSDateFormatter alloc] init];
        absenceDateFormater.dateFormat = @"YYYY-MM-dd";
        
        NSDateFormatter *latesDateFormater = [[NSDateFormatter alloc] init];
        latesDateFormater.dateFormat = @"HH:mm";
        
        NSMutableString *hours = [[NSMutableString alloc] initWithString:@""];
        
        void(^setAbsences)(void) = ^(void) {
            cell.clockView.color = MAIN_RED_COLOR;
            
            [user.absences enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
                RMAbsence *absence = (RMAbsence *)obj;
                
                if ((currentListState != ListStateOutTomorrow && [absence.isTomorrow boolValue] == NO)
                    ||
                    (currentListState == ListStateOutTomorrow && [absence.isTomorrow boolValue] == YES)
                    )
                {
                    NSString *start = [absenceDateFormater stringFromDate:absence.start];
                    NSString *stop = [absenceDateFormater stringFromDate:absence.stop];
                    
                    if (start.length || stop.length)
                    {
                        [hours appendFormat:@" %@  -  %@\n", start.length ? start : @"...",
                         stop.length ? stop : @"..."];
                    }
                }
            }];
            
        };
        
        void(^setLates)(void) = ^(void) {
            cell.clockView.color = MAIN_YELLOW_COLOR;
            
            [user.lates enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
                RMLate *late = (RMLate *)obj;
                
                if ((currentListState != ListStateOutTomorrow && [late.isTomorrow boolValue] == NO)
                    ||
                    (currentListState == ListStateOutTomorrow && [late.isTomorrow boolValue] == YES)
                    )
                {
                    NSString *start = [latesDateFormater stringFromDate:late.start];
                    NSString *stop = [latesDateFormater stringFromDate:late.stop];
                    
                    if (start.length || stop.length)
                    {
                        [hours appendFormat:@" %@ - %@\n", start.length ? start : @"...",
                         stop.length ? stop : @"..."];
                    }
                }
            }];
        };
        
        if (currentListState == ListStateAll)
        {
            if (user.lates.count)
            {
                setLates();
            }
            else if (user.absences.count)
            {
                setAbsences();
            }
        }
        else
        {
            if (indexPath.section == 1 || indexPath.section == 2)
            {
                setLates();
            }
            else if (indexPath.section == 0)
            {
                setAbsences();
            }
        }

        [hours setString:[hours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];

        cell.warningDateLabel.text = hours;
    }

    if (user.avatarURL)
    {
        BOOL refresh = [avatarsToRefresh containsObject:user.id];
        [cell.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:user.avatarURL]
                                       forceRefresh:refresh];
        
        if (refresh)
        {
            [avatarsToRefresh removeObject:user.id];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.rowHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (currentListState != ListStateAll)
    {
        switch (section)
        {
            case 0:
                return @"ABSENCE / HOLIDAY";
                
            case 1:
                return @"WORK FROM HOME";
                
            case 2:
                return @"OUT OF OFFICE";
        }
    }
    
    return @"";
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[UserDetailsTableViewController class]])
    {
        UserListCell *cell = (UserListCell *)sender;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        if (indexPath == nil)
        {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
        }
        
        currentIndexPath = indexPath;
        
        if (currentListState == ListStateAll)
        {
            ((UserDetailsTableViewController *)segue.destinationViewController).user = _userList[indexPath.row];
        }
        else
        {
            if (indexPath.section == 0)
            {
                ((UserDetailsTableViewController *)segue.destinationViewController).isComeFromAbsences = YES;
            }
            
            ((UserDetailsTableViewController *)segue.destinationViewController).user = _userList[indexPath.section][indexPath.row];
        }
        
        ((UserDetailsTableViewController *)segue.destinationViewController).isListStateTommorow = currentListState == ListStateOutTomorrow;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (myPopover)
    {
        [myPopover dismissPopoverAnimated:YES];
        
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)showNoSelectionUserDetails
{
    if (INTERFACE_IS_PAD)
    {
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"NoSelectionUserDetails"];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        nvc.navigationBar.tintColor = MAIN_APP_COLOR;
        
        self.splitViewController.viewControllers = @[self.splitViewController.viewControllers[0], nvc];
    }
}

- (IBAction)showPlaningPoker:(id)sender
{
    PlaningPokerViewController *ppvc = [[PlaningPokerViewController alloc] initWithNibName:@"PlaningPokerViewController" bundle:nil];
    ppvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:ppvc];
    
    if (BLURED_BACKGROUND)
    {
        ppvc.backgroundImage = [self.view.superview.superview.superview convertViewToImage];
        [nvc setNavigationBarHidden:YES animated:NO];
    }
    
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - Add OOO

- (IBAction)showNewRequest:(id)sender
{
    [self.requestActionSheet dismissWithClickedButtonIndex:20 animated:NO];
    [self.popover dismissPopoverAnimated:NO];
    
    self.requestActionSheet = [[UIActionSheet alloc] initWithTitle:@"New request" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Absence / Holiday", @"Out of office", nil];
    
    if (INTERFACE_IS_PHONE)
    {
        [self.requestActionSheet showInView:self.view];
    }
    else
    {
        [self.requestActionSheet showFromBarButtonItem:self.addRequestButton animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < 2)
    {
        UINavigationController *nvc = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"AddOOOFormTableViewControllerId"];
        
        AddOOOFormTableViewController *outOfOfficeForm = [nvc.viewControllers firstObject];
        outOfOfficeForm.currentRequest = buttonIndex;
        
        if (INTERFACE_IS_PAD)
        {
            self.popover = [[UIPopoverController alloc] initWithContentViewController:nvc];
            self.popover.delegate = self;

            if (iOS8_PLUS)
            {
                [self performBlockOnMainThread:^{ //hack, popover don't show on ios 8
                    [self.popover presentPopoverFromBarButtonItem:self.addRequestButton
                                         permittedArrowDirections:UIPopoverArrowDirectionUp
                                                         animated:NO];
                    outOfOfficeForm.popover = self.popover;
                } afterDelay:0];
            }
            else
            {
                [self.popover presentPopoverFromBarButtonItem:self.addRequestButton
                                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                                     animated:NO];
                outOfOfficeForm.popover = self.popover;
            }
        }
        else
        {
            [self presentViewController:nvc animated:YES completion:nil];
        }
    }
}

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
        }
        
        self.viewSwitchButton.enabled = YES;
        [self.navigationItem setLeftBarButtonItem:self.viewSwitchButton animated:YES];
    } afterDelay:0];
}

- (ListState)nextListState
{
    switch (currentListState)
    {
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
