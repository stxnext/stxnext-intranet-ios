//
//  UserTableViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UserTableViewController.h"
#import "APIRequest.h"
#import "AFHTTPRequestOperation+Redirect.h"
#import "UserListCell.h"
#import "UserDetailsTableViewController.h"
#import "PlaningPokerViewController.h"
#import "UIView+Screenshot.h"
#import "AppDelegate+Settings.h"

static CGFloat statusBarHeight;
static CGFloat navBarHeight;
static CGFloat tabBarHeight;

@implementation UserTableViewController
{
    __weak UIPopoverController *myPopover;
    BOOL canShowNoResultsMessage;
    
    NSString *searchedString;
    NSIndexPath *currentIndexPath;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[UserListCell cellId]];
    
    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    navBarHeight = self.navigationController.navigationBar.frame.size.height;
    tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    searchedString = @"";
    _actionSheet = nil;
    _userList = [NSArray array];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refresh"];
    [refresh addTarget:self action:@selector(startRefreshData)forControlEvents:UIControlEventValueChanged];
    _refreshControl = refresh;
    self.refreshControl = refresh;
    
    [_tableView hideEmptySeparators];
    [self.searchDisplayController.searchResultsTableView hideEmptySeparators];
    
    self.title = @"All";
    
    //update data
    if ([APP_DELEGATE userLoggedType] != UserLoginTypeNO)
    {
        [self loadUsersFromAPIWithNotification];
    }
    
    if ([APP_DELEGATE userLoggedType] == UserLoginTypeFalse || [APP_DELEGATE userLoggedType] == UserLoginTypeError)
    {
        [self.tabBarController.tabBar.items[2] setTitle:@"About"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (currentIndexPath)
    {
        [_tableView deselectRowAtIndexPath:currentIndexPath animated:YES];
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
                                              
                                              [self.tabBarController.tabBar.items[2] setTitle:@"Me"];
                                              
                                              [self loadUsersFromAPI];
                                          }
                                          else
                                          {
                                              //error with login (e.g. account not exists)
                                              [APP_DELEGATE setUserLoggedType:UserLoginTypeFalse];
                                              
                                              [self.tabBarController.tabBar.items[2] setTitle:@"About"];
                                              
                                              [self loadUsersFromAPI];
                                          }
                                      }];
}

- (void)startRefreshData
{
    [self showNoSelectionUserDetails];
    
    _showActionButton.enabled = NO;
    _showPlanningPokerButton.enabled = NO;
    
    [self loadUsersFromAPI];
}

- (void)stopRefreshData
{
    [_refreshControl endRefreshing];
    
    _showActionButton.enabled = YES;
    _showPlanningPokerButton.enabled = YES;
}

- (void)loadUsers
{
    // First try to load from CoreData
    [self loadUsersFromDatabase];
    
    // If there are no users in CoreData, load from API
    if (!_userList || _userList.count == 0)
    {
        [self loadUsersFromAPI];
    }
    
    // Refresh GUI
    [_tableView reloadData];
    [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
}

- (void)loadUsersFromDatabase
{
    /*
    {
        NSArray *teams = [JSONSerializationHelper objectsWithClass:[RMTeam class]
                                                withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                                 ascending:YES
                                                                                                  selector:@selector(localizedCompare:)]
                                                     withPredicate:nil
                                                  inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
        
        
//        for (RMTeam *team in teams)
//        {
//            NSLog(@"team name %@", team.name);
//            NSLog(@"team id %i", [team.id intValue]);
//            
//            for (RMUser *user in team.users)
//            {
//                NSLog(@"team user %@", user.name);
//            }
//            NSLog(@" " );
//        }

    }
    */
    
    DDLogInfo(@"Loading from: Database");
    
    NSArray *users = [JSONSerializationHelper objectsWithClass:[RMUser class]
                                            withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                             ascending:YES
                                                                                              selector:@selector(localizedCompare:)]
                                                 withPredicate:[NSPredicate predicateWithFormat:@"isActive = YES"]
                                              inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
    /*
    for (RMUser *user in users)
    {
        NSLog(@"USER %@", user.name);
        for (RMTeam *team in user.teams)
        {
            NSLog(@"TEAM %@", team.name);
        }
        
        NSLog(@" ");
    }
    */
    
    self.filterStructure = [[NSMutableArray alloc] init];
    
    NSArray *types = @[WORKERS, CLIENTS, FREELANCERS];
    NSArray *people = @[ALL, PRESENT, ABSENT, LATE];
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    NSMutableArray *roles = [[NSMutableArray alloc] init];
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    for (RMUser *user in users)
    {
        if (user.location && ![user.isClient boolValue])
        {
            if (![locations containsObject:user.location])
            {
                [locations addObject:user.location];
            }
        }
        
        if (user.roles && ![user.isClient boolValue])
        {
            for (NSString *role in user.roles)
            {
                if (![roles containsObject:role])
                {
                    [roles addObject:role];
                }
            }
        }
        
        if (user.groups && ![user.isClient boolValue])
        {
            for (NSString *group in user.groups)
            {
                if (![groups containsObject:group])
                {
                    [groups addObject:group];
                }
            }
        }
    }
    
    [self.filterStructure addObject:types];
    [self.filterStructure addObject:people];
    
    [self.filterStructure addObject:[locations sortedArrayUsingSelector:@selector(localizedCompare:)]];
    [self.filterStructure addObject:[roles sortedArrayUsingSelector:@selector(localizedCompare:)]];
    [self.filterStructure addObject:[groups sortedArrayUsingSelector:@selector(localizedCompare:)]];
    
    if (self.filterSelections == nil)
    {
        self.filterSelections = [NSMutableArray arrayWithArray:@[
                                                                 [NSMutableArray arrayWithArray:@[WORKERS]],
                                                                 [NSMutableArray arrayWithArray:@[ALL]],
                                                                 [[NSMutableArray alloc] init],
                                                                 [[NSMutableArray alloc] init],
                                                                 [[NSMutableArray alloc] init]
                                                                 ]];
    }
    
    if (searchedString.length > 0)
    {
        users = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]];
    }
    
    if ([self.filterSelections[0][0] isEqualToString:WORKERS])
    {
        _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClient = NO AND isFreelancer = NO"]];
        
        if ([self.filterSelections[1][0] isEqualToString:ALL])
        {
            
        }
        else if ([self.filterSelections[1][0] isEqualToString:PRESENT])
        {
            _userList = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"absences.@count = 0 && lates.@count = 0"]];
        }
        else if ([self.filterSelections[1][0] isEqualToString:ABSENT])
        {
            _userList = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"absences.@count > 0"]];
        }
        else if ([self.filterSelections[1][0] isEqualToString:LATE])
        {
            _userList = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lates.@count > 0"]];
        }
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
        if ([self.filterSelections[2] count])
        {
            [tempArray removeAllObjects];
            
            for (NSString *location in self.filterSelections[2])
            {
                NSArray *filteredArray = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    if ([((RMUser *)evaluatedObject).location isEqualToString:location])
                    {
                        return YES;
                    }
                    
                    return NO;
                }]];
                
                if ([filteredArray count])
                {
                    [tempArray addObjectsFromArray:filteredArray];
                }
            }
            
            _userList = [NSArray arrayWithArray:tempArray];
        }
        
        if ([self.filterSelections[3] count])
        {
            [tempArray removeAllObjects];
            
            for (NSString *role in self.filterSelections[3])
            {
                NSArray *filteredArray = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    for (NSString *str in ((RMUser *)evaluatedObject).roles)
                    {
                        if ([str isEqualToString:role])
                        {
                            return YES;
                        }
                    }
                    
                    return NO;
                }]];
                
                if ([filteredArray count])
                {
                    [tempArray addObjectsFromArray:filteredArray];
                }
            }
            
            _userList = [NSArray arrayWithArray:tempArray];
        }
        
        if ([self.filterSelections[4] count])
        {
            [tempArray removeAllObjects];
            
            for (NSString *group in self.filterSelections[4])
            {
                NSArray *filteredArray = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    for (NSString *str in ((RMUser *)evaluatedObject).groups)
                    {
                        if ([str isEqualToString:group])
                        {
                            return YES;
                        }
                    }
                    
                    return NO;
                }]];
                
                if ([filteredArray count])
                {
                    [tempArray addObjectsFromArray:filteredArray];
                }
            }
            
            _userList = [NSArray arrayWithArray:tempArray];
        }
    }
    else if ([self.filterSelections[0][0] isEqualToString:CLIENTS])
    {
        _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClient = YES"]];
    }
    else if ([self.filterSelections[0][0] isEqualToString:FREELANCERS])
    {
        _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isFreelancer = YES"]];
    }
    
    [_tableView reloadData];
}

- (void)loadUsersFromAPIWithNotification
{
    [self.refreshControl beginRefreshing];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
        self.tableView.contentOffset = CGPointMake(0, -_refreshControl.frame.size.height);
    } completion:^(BOOL finished){
        [self startRefreshData];
    }];
}

- (void)loadUsersFromAPI
{
    if (![[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        [self stopRefreshData];
        [self loadUsers];
        
        return;
    }
    
    __block NSInteger operations = 3;
    __block BOOL deletedUsers = NO;
    
    DDLogInfo(@"Loading from: API");
    
    [self.filterSelections removeAllObjects];
    [self.filterStructure removeAllObjects];
    
    self.filterSelections = nil;
    self.filterStructure = nil;
    
    [[HTTPClient sharedClient] startOperation:[APP_DELEGATE userLoggedType] == UserLoginTypeTrue ? [APIRequest getUsers] : [APIRequest getFalseUsers]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          // Delete from database
                                          @synchronized (self)
                                          {
                                              if (!deletedUsers)
                                              {
                                                  [JSONSerializationHelper deleteObjectsWithClass:[RMUser class]
                                                                                 inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                                                  deletedUsers = YES;
                                              }
                                          }
                                          
                                          // Add to database
                                          for (id user in responseObject[@"users"])
                                          {
                                              [RMUser mapFromJSON:user];
                                          }
     
                                          DDLogInfo(@"Loaded From API: %lu users", (unsigned long)[responseObject[@"users"] count]);
                                          
                                          // Save database
                                          [[DatabaseManager sharedManager] saveContext];
                                          
                                          // Load from database
                                          [self loadUsersFromDatabase];
                                          
                                          if (--operations == 0)
                                          {
                                              [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          
                                          DDLogError(@"Users API Loading Error");
                                          [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                          
                                          if ([operation redirectToLoginView])
                                          {
                                              [self showLoginScreen];
                                          }
                                          
                                          --operations;
                                          [self loadUsersFromDatabase];
                                      }];
    
    [[HTTPClient sharedClient] startOperation:[APP_DELEGATE userLoggedType] == UserLoginTypeTrue ? [APIRequest getPresence] : [APIRequest getFalsePresence]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          // Delete from database'

                                          @synchronized (self)
                                          {
                                              if (!deletedUsers)
                                              {
                                                  [JSONSerializationHelper deleteObjectsWithClass:[RMUser class]
                                                                                 inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                                                  deletedUsers = YES;
                                              }
                                              
                                              [JSONSerializationHelper deleteObjectsWithClass:[RMAbsence class]
                                                                             inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                                              
                                              [JSONSerializationHelper deleteObjectsWithClass:[RMLate class]
                                                                             inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                                          }
                                          
                                          // Add to database
                                          for (id absence in responseObject[@"absences"])
                                          {
                                              [RMAbsence mapFromJSON:absence];
                                          }
                                          
                                          for (id late in responseObject[@"lates"])
                                          {
                                              [RMLate mapFromJSON:late];
                                          }
                                          
                                          // Save database
                                          [[DatabaseManager sharedManager] saveContext];
                                          
                                          DDLogInfo(@"Loaded: absences and lates");
                                          
                                          // Load from database
                                          [self loadUsersFromDatabase];
                                          
                                          if (--operations == 0)
                                          {
                                              [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          DDLogError(@"Presence API Loading Error");
                                          
                                          --operations;
                                          [self loadUsersFromDatabase];
                                      }];
    
    [[HTTPClient sharedClient] startOperation:[APP_DELEGATE userLoggedType] == UserLoginTypeTrue ? [APIRequest getTeams] : [APIRequest getFalseTeams]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          // Delete from database'
                                          
                                          @synchronized (self)
                                          {
                                              if (!deletedUsers)
                                              {
                                                  [JSONSerializationHelper deleteObjectsWithClass:[RMUser class]
                                                                                 inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                                                  deletedUsers = YES;
                                              }
                                              
                                              [JSONSerializationHelper deleteObjectsWithClass:[RMTeam class]
                                                                             inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                                          }
                                          
                                          // Add to database

                                          for (id team in responseObject[@"teams"])
                                          {
                                              [RMTeam mapFromJSON:team];
                                          }
                                          
                                          // Save database
                                          [[DatabaseManager sharedManager] saveContext];
                                          
                                          DDLogInfo(@"Loaded: teams");

                                          // Load from database
                                          [self loadUsersFromDatabase];

                                          if (--operations == 0)
                                          {
                                              [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          DDLogError(@"Teams API Loading Error");
                                          
                                          --operations;
                                          [self loadUsersFromDatabase];
                                      }];
}

#pragma mark - Filter delegate

- (void)changeFilterSelections:(NSArray *)filterSelection
{
    canShowNoResultsMessage = YES;
    self.filterSelections = [[NSMutableArray alloc] init];
    
    for (id obj in filterSelection)
    {
        [self.filterSelections addObject:[NSMutableArray arrayWithArray:obj]];
    }
    
    [self showNoSelectionUserDetails];
    
    [self loadUsersFromDatabase];
    
    [_tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = _userList.count;
    
    if (number == 0 && canShowNoResultsMessage)
    {
        [UIAlertView showErrorWithMessage:@"Nothing to show." handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            canShowNoResultsMessage = NO;
            [self performBlockOnMainThread:^{
                self.filterSelections = nil;
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
    UserListCell *cell = [_tableView dequeueReusableCellWithIdentifier:[UserListCell cellId]];
    
    if (!cell)
    {
        cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UserListCell cellId]];
    }
    
    RMUser *user = _userList[indexPath.row];
    
    cell.user = user;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetailsTableViewController *userDetailsTVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"UserDetailsTableViewControllerId"];
    currentIndexPath = indexPath;

    userDetailsTVC.user = _userList[indexPath.row];
    
    if (INTERFACE_IS_PAD)
    {
//        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"NoSelectionUserDetails"];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:userDetailsTVC];
        nvc.navigationBar.tintColor = MAIN_APP_COLOR;
        self.splitViewController.viewControllers = @[self.splitViewController.viewControllers[0], nvc];
    }
    else
    {
        [self.navigationController pushViewController:userDetailsTVC animated:YES];
    }
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FilterSegue"])
    {
        if (self.filterSelections)
        {
            ((FilterViewController *)(((UINavigationController *)segue.destinationViewController).visibleViewController)).filterStructure = self.filterStructure;
            [((FilterViewController *)(((UINavigationController *)segue.destinationViewController).visibleViewController)) setFilterSelection:self.filterSelections];
            ((FilterViewController *)(((UINavigationController *)segue.destinationViewController).visibleViewController)).delegate = self;
        }
    }
    else if ([segue.identifier isEqualToString:@"FilterPopoverSegue"])
    {
        myPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        
        ((FilterViewController *)(((UINavigationController *)segue.destinationViewController).visibleViewController)).filterStructure = self.filterStructure;
        [((FilterViewController *)(((UINavigationController *)segue.destinationViewController).visibleViewController)) setFilterSelection:self.filterSelections];
        ((FilterViewController *)(((UINavigationController *)segue.destinationViewController).visibleViewController)).delegate = self;
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
    
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
