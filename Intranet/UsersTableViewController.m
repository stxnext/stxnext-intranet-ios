//
//  UserTableViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UsersTableViewController.h"

#import "AFHTTPRequestOperation+Redirect.h"


#import "UserListCell.h"
#import "UserDetailsTableViewController.h"
#import "PlaningPokerViewController.h"
#import "UIView+Screenshot.h"
#import "CurrentUser.h"
#import "Model.h"

static CGFloat statusBarHeight;
static CGFloat navBarHeight;
static CGFloat tabBarHeight;

@implementation UsersTableViewController
{
    __weak UIPopoverController *myPopover;
    BOOL canShowNoResultsMessage;
    
    NSString *searchedString;
    NSIndexPath *currentIndexPath;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[UserListCell cellId]];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"UserListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[UserListCell cellId]];
    self.searchDisplayController.searchResultsTableView.rowHeight = self.tableView.rowHeight;
    
    searchedString = @"";
    _userList = [NSArray array];
    self.title = @"All";
    
    if ([[CurrentUser singleton] userLoginType] == UserLoginTypeFalse || [[CurrentUser singleton] userLoginType] == UserLoginTypeError)
    {
        [self.tabBarController.tabBar.items[2] setTitle:@"About"];
    }
    
    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    navBarHeight = self.navigationController.navigationBar.frame.size.height;
    tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    [self.tableView hideEmptySeparators];
    [self.searchDisplayController.searchResultsTableView hideEmptySeparators];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refresh"];
    [refresh addTarget:self action:@selector(downloadUsers)forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    
    //update data
    if ([[CurrentUser singleton] userLoginType] != UserLoginTypeNO)
    {
        //[self downloadUsers];
        [self loadUsers];
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
    
    if ([[CurrentUser singleton] userLoginType] == UserLoginTypeNO)
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

#pragma mark - Users

- (void)loadUsers
{
    [[Users singleton] usersWithStart:^{
        
        [self.refreshControl endRefreshing];
        [LoaderView showWithRefreshControl:self.refreshControl tableView:self.tableView];
        
    } end:^{
        
        [self.tableView reloadData];
        [LoaderView hideWithRefreshControl:self.refreshControl tableView:self.tableView];
        
    } success:^(NSArray *users) {
        
        if (searchedString.length > 0)
        {
            _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@ AND isClient = NO AND isFreelancer = NO", searchedString]];
        }
        else
        {
            _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClient = NO AND isFreelancer = NO"]];;
        }
        
        //obsługa filtrów
        /*
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
         */
    } failure:^(NSArray *cachedUsers, FailureErrorType error) {
       
        if (error == FailureErrorTypeLoginRequired)
        {
            [self showLoginScreen];
        }
    }];
}

- (void)downloadUsers
{    
    [self.filterSelections removeAllObjects];
    [self.filterStructure removeAllObjects];
    
    self.filterSelections = nil;
    self.filterStructure = nil;
    
    [[Model singleton] updateModelWithStart:^{

        self.tableView.hidden = YES;
        [LoaderView showWithRefreshControl:self.refreshControl tableView:self.tableView];
    
    } end:^{
        
        [self.tableView reloadData];
        [LoaderView hideWithRefreshControl:self.refreshControl tableView:self.tableView];

    } success:^(NSArray *users, NSArray *presences, NSArray *teams) {
        
        if (searchedString.length > 0)
        {
            _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@ AND isClient = NO AND isFreelancer = NO", searchedString]];
        }
        else
        {
            _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClient = NO AND isFreelancer = NO"]];;
        }
        
    } failure:^(NSArray *cachedUsers, NSArray *cachedPresences, NSArray *cachedTeams , FailureErrorType error) {
        
        switch (error)
        {
            case FailureErrorTypeDefault:
            {
                [self loadUsers];
            }
                break;
                
            case FailureErrorTypeLoginRequired:
            {
                _userList = nil;
                [self.tableView reloadData];
                [self showLoginScreen];
            }
                break;
        }
    }];
}

#pragma mark - Login delegate

- (void)showLoginScreen
{
    [self showNoSelectionUserDetails];
    
    [LoginViewController presentAfterSetupWithDecorator:^(UIModalViewController *controller) {
        
        LoginViewController *customController = (LoginViewController *)controller;
        customController.delegate = self;
    }];
}

- (void)loginViewController:(LoginViewController *)loginViewController finishedLoginWithUserLoginType:(UserLoginType)userLoginType
{
    switch (userLoginType)
    {
        case UserLoginTypeTrue:
        {
            [self.tabBarController.tabBar.items[2] setTitle:@"Me"];
            
            [self downloadUsers];
        }
            break;
            
        case UserLoginTypeFalse:
        {
            [self.tabBarController.tabBar.items[2] setTitle:@"About"];
            
            [self downloadUsers];
        }
            break;

        case UserLoginTypeError:
        {

        }
            break;

        default:
            break;
    }
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
    
    [self loadUsers];
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
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
    
    [self loadUsers];
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
        [UIAlertView showErrorWithMessage:@"Nothing to show."
                                  handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      
                                      canShowNoResultsMessage = NO;
                                      
                                      [self performBlockOnMainThread:^{
                                          
                                          self.filterSelections = nil;
                                          [self loadUsers];
                                          
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
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:[UserListCell cellId]];
    
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
    return tableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetailsTableViewController *userDetailsTVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"UserDetailsTableViewControllerId"];
    currentIndexPath = indexPath;
    
    userDetailsTVC.user = _userList[indexPath.row];
    
    if (INTERFACE_IS_PAD)
    {
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
            FilterViewController *filterVC = (FilterViewController *)(((UINavigationController *)segue.destinationViewController).visibleViewController);
            
            filterVC.filterStructure = self.filterStructure;
            [filterVC setFilterSelection:self.filterSelections];
            filterVC.delegate = self;
        }
    }
    else if ([segue.identifier isEqualToString:@"FilterPopoverSegue"])
    {
        myPopover = [(UIStoryboardPopoverSegue *)segue popoverController];
        
        FilterViewController *filterVC = (FilterViewController *)(((UINavigationController *)segue.destinationViewController).visibleViewController);
        
        filterVC.filterStructure = self.filterStructure;
        [filterVC setFilterSelection:self.filterSelections];
        filterVC.delegate = self;
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
