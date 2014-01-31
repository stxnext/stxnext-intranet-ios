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

static CGFloat statusBarHeight;
static CGFloat navBarHeight;
static CGFloat tabBarHeight;

@implementation UserTableViewController
{
    __weak UIPopoverController *myPopover;
    
    NSString *searchedString;
    NSIndexPath *currentIndexPath;
    
//    BOOL keyboardVisible;
//    BOOL searchBarVisible;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    navBarHeight = self.navigationController.navigationBar.frame.size.height;
    tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
//    keyboardVisible = NO;
//    searchBarVisible = NO;
    
//    [self updateGuiForBarState:searchBarVisible];
    
    searchedString = @"";
    _actionSheet = nil;
    _userList = [NSArray array];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Odśwież"];
    [refresh addTarget:self action:@selector(startRefreshData)forControlEvents:UIControlEventValueChanged];
    _refreshControl = refresh;
    self.refreshControl = refresh;
    
    [_tableView hideEmptySeparators];
    self.title = @"Lista osób";
    
    [self loadUsersFromDatabase];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (currentIndexPath)
    {
        [_tableView deselectRowAtIndexPath:currentIndexPath animated:YES];
        currentIndexPath = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[HTTPClient sharedClient] authCookiesPresent])
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
    
//    [self updateGuiForBarState:searchBarVisible];
}

#pragma mark Login delegate

- (void)showLoginScreen
{
    [LoginViewController presentAfterSetupWithDecorator:^(UIModalViewController *controller) {
        LoginViewController* customController = (LoginViewController*)controller;
        customController.delegate = self;
    }];
}

- (void)finishedLoginWithCode:(NSString*)code withError:(NSError*)error
{
    // Assume success, use code to fetch cookies
    [[HTTPClient sharedClient] startOperation:[APIRequest loginWithCode:code]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          // We expect 302
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:operation.response.allHeaderFields forURL:operation.response.URL];
                                          
                                          [[HTTPClient sharedClient] saveCookies:cookies];
                                          
                                          // If redirected properly
                                          if (operation.response.statusCode == 302 && cookies)
                                          {
                                              [self loadUsersFromAPI];
                                          }
                                      }];
}

- (void)startRefreshData
{
    _showActionButton.enabled = NO;
    [self loadUsersFromAPI];
}

- (void)stopRefreshData
{
    [_refreshControl endRefreshing];
    _showActionButton.enabled = YES;
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
    NSLog(@"Loading from: Database");
    
    NSArray *users = [JSONSerializationHelper objectsWithClass:[RMUser class]
                                            withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCompare:)]
                                                 withPredicate:nil //[NSPredicate predicateWithFormat:@"location = 'Wrocław'"]
                                              inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
    
    NSLog(@"%@", users);
    
    self.filterStructure = [[NSMutableArray alloc] init];

    NSArray *types = @[@"Pracownicy", @"Klienci", @"Freelancers"];
    NSArray *people = @[@"Wszyscy", @"Obecni", @"Nieobecni", @"Spóźnienia"];
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    NSMutableArray *roles = [[NSMutableArray alloc] init];
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    for (RMUser *user in users)
    {
        if (user.location)
        {
            if (![locations containsObject:user.location])
            {
                [locations addObject:[user.location capitalizedString]];
            }
        }
        
        if (user.roles)
        {
            for (NSString *role in user.roles)
            {
                if (![roles containsObject:[role capitalizedString]])
                {
                    [roles addObject:[role capitalizedString]];
                }
            }
        }
        
        if (user.groups)
        {
            for (NSString *group in user.groups)
            {
                if (![groups containsObject:[group capitalizedString]])
                {
                    [groups addObject:[group capitalizedString]];
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
                                                                 [NSMutableArray arrayWithArray:@[@"Pracownicy"]],
                                                                 [NSMutableArray arrayWithArray:@[@"Wszyscy"]],
                                                                 [[NSMutableArray alloc] init],
                                                                 [[NSMutableArray alloc] init],
                                                                 [[NSMutableArray alloc] init]
                                                                 ]];
    }
    
    if (searchedString.length > 0)
    {
        _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]];
    }
    else
    {
        if ([self.filterSelections[0][0] isEqualToString:@"Pracownicy"])
        {
            _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClient = NO AND isFreelancer = NO"]];
            
            if ([self.filterSelections[1][0] isEqualToString:@"Wszyscy"])
            {
                
            }
            else if ([self.filterSelections[1][0] isEqualToString:@"Obecni"])
            {
                _userList = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"absences.@count = 0 && lates.@count = 0"]];
            }
            else if ([self.filterSelections[1][0] isEqualToString:@"Nieobecni"])
            {
                _userList = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"absences.@count > 0"]];
            }
            else if ([self.filterSelections[1][0] isEqualToString:@"Spóźnienia"])
            {
                [_userList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSLog(@"%@", ((RMUser *)obj).name);
                    NSLog(@"%i", [((RMUser *)obj).lates count]);
                }];
                
                _userList = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lates.@count > 0"]];
            }
            
            for (NSString *location in self.filterSelections[2])
            {
                _userList = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"location = %@", location]];
            }
            
            for (NSString *role in self.filterSelections[3])
            {
                _userList = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    for (NSString *str in ((RMUser *)evaluatedObject).roles)
                    {
                        if ([[str capitalizedString] isEqualToString:role])
                        {
                            return YES;
                        }
                    }
                    
                    return NO;
                }]];
            }
            
            for (NSString *group in self.filterSelections[4])
            {
                _userList = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                    for (NSString *str in ((RMUser *)evaluatedObject).groups)
                    {
                        if ([[str capitalizedString] isEqualToString:group])
                        {
                            return YES;
                        }
                    }
                    
                    return NO;
                }]];
            }
        }
        else if ([self.filterSelections[0][0] isEqualToString:@"Klienci"])
        {
            _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClient = YES"]];
        }
        else if ([self.filterSelections[0][0] isEqualToString:@"Freelancers"])
        {
            _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isFreelancer = YES"]];
        }
    }

    NSLog(@"\nusers: %d\nlates: %d\nabsences: %d",
          [JSONSerializationHelper objectsWithClass:[RMUser class]
                                 withSortDescriptor:nil
                                      withPredicate:nil
                                   inManagedContext:[DatabaseManager sharedManager].managedObjectContext].count,
          [JSONSerializationHelper objectsWithClass:[RMLate class]
                                 withSortDescriptor:nil
                                      withPredicate:nil
                                   inManagedContext:[DatabaseManager sharedManager].managedObjectContext].count,
          [JSONSerializationHelper objectsWithClass:[RMAbsence class]
                                 withSortDescriptor:nil
                                      withPredicate:nil
                                   inManagedContext:[DatabaseManager sharedManager].managedObjectContext].count);
    
    [_tableView reloadData];
}

- (void)clearDetailsController
{
    UIViewController *detailController = self.splitViewController.viewControllers.lastObject;
    
    if (![detailController isKindOfClass:[UINavigationController class]])
    {
        return;
    }
    
    UINavigationController* navigationController = (UINavigationController*)detailController;
    [navigationController setViewControllers:@[ [UIViewController new] ]];
}

- (void)loadUsersFromAPI
{
    __block NSInteger operations = 2;
    __block BOOL deletedUsers = NO;
    
    NSLog(@"Loading from: API");
    
    [self.filterSelections removeAllObjects];
    [self.filterStructure removeAllObjects];
    
    self.filterSelections = nil;
    self.filterStructure = nil;
    
    [[HTTPClient sharedClient] startOperation:[APIRequest getUsers]
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
                                              [RMUser mapFromJSON:user];
                                          
                                          // Save database
                                          [[DatabaseManager sharedManager] saveContext];
                                          
                                          // Load from database
                                          [self loadUsersFromDatabase];
                                          [self clearDetailsController];
                                          
                                          if (--operations == 0)
                                              [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Loaded: 0 users");
                                          [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                          
                                          if ([operation redirectToLoginView])
                                          {
                                              [self showLoginScreen];
                                          }
                                      }];
    
    [[HTTPClient sharedClient] startOperation:[APIRequest getPresence]
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
                                              
                                              [JSONSerializationHelper deleteObjectsWithClass:[RMAbsence class]
                                                                             inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                                              [JSONSerializationHelper deleteObjectsWithClass:[RMLate class]
                                                                             inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                                          }
                                          
                                          // Add to database
                                          for (id absence in responseObject[@"absences"])
                                              [RMAbsence mapFromJSON:absence];
                                          
                                          for (id late in responseObject[@"lates"])
                                              [RMLate mapFromJSON:late];
                                          
                                          // Save database
                                          [[DatabaseManager sharedManager] saveContext];
                                          
                                          NSLog(@"Loaded: absences and lates");
                                          
                                          // Load from database
                                          [self loadUsersFromDatabase];
                                          [self clearDetailsController];
                                          
                                          if (--operations == 0)
                                              [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                      }
                                      failure:nil];
}

#pragma mark - Filter delegate

- (void)changeFilterSelections:(NSArray *)filterSelection
{
    self.filterSelections = [[NSMutableArray alloc] init];
    
    for (id obj in filterSelection)
    {
        [self.filterSelections addObject:[NSMutableArray arrayWithArray:obj]];
    }
    
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

- (void)reloadSearchWithText:(NSString*)text
{
    searchedString = text;
    
    [self loadUsersFromDatabase];
}

/*
- (void)updateGuiForBarState:(BOOL)barVisible
{

    if (iOS7_PLUS)
    {
        self.searchBarTopConstraint.constant = barVisible ? statusBarHeight + navBarHeight : statusBarHeight
                                                        + navBarHeight - _searchBar.frame.size.height;
        self.tableViewBottomConstraint.constant = tabBarHeight;
    }
    else
    {
        self.searchBarTopConstraint.constant = barVisible ? 0.0f : -_searchBar.frame.size.height;
        self.tableViewBottomConstraint.constant = 0.0f;
    }
    
    [_searchBar layoutIfNeeded];
    [_tableView layoutIfNeeded];

}
 */
/*
- (void)showSearchBar:(UISearchBar *)searchBar animated:(BOOL)animated
{
    _searchBar.text = @"";
    searchBarVisible = YES;
    
    [UIView animateWithDuration:0.33 animations:^{
        [self updateGuiForBarState:searchBarVisible];
    }];
    
    double delayInSeconds = 0.33;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_searchBar becomeFirstResponder];
        [self.searchDisplayController.searchResultsTableView hideEmptySeparators];
    });
}
*/
/*
- (void)hideSearchBar:(UISearchBar *)searchBar animated:(BOOL)animated
{
    [_searchBar resignFirstResponder];
    
    if (animated)
    {
        [UIView animateWithDuration:0.33 animations:^{
            [self updateGuiForBarState:NO];
        } completion:^(BOOL finished) {
            searchBarVisible = NO;
        }];
    }
    else
    {
        [self updateGuiForBarState:NO];
        searchBarVisible = NO;
    }
    
    double delayInSeconds = 0.33;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self reloadSearchWithText:@""];
    });
}
*/
#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self reloadSearchWithText:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
//    [self hideSearchBar:searchBar animated:YES];
    //_refreshControl.alpha = 1.0f;
    [self reloadSearchWithText:@""];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int number = _userList.count;
    
    self.notFoundLabel.hidden = number != 0;
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMUser *user = _userList[indexPath.row];
    
    static NSString *CellIdentifier = @"UserCell";
    
    UserListCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.userName.text = user.name;
    cell.userImage.layer.cornerRadius = 5;
    cell.userImage.clipsToBounds = YES;

    cell.clockView.hidden = ((user.lates.count + user.absences.count) == 0);
    cell.warningDateLabel.hidden = ((user.lates.count + user.absences.count) == 0);
    
    NSDateFormatter *absenceDateFormater = [[NSDateFormatter alloc] init];
    absenceDateFormater.dateFormat = @"YYYY-MM-dd";

    NSDateFormatter *latesDateFormater = [[NSDateFormatter alloc] init];
    latesDateFormater.dateFormat = @"HH:mm";
    
    __block NSMutableString *hours = [[NSMutableString alloc] initWithString:@""];
   
    if (user.lates.count)
    {
        cell.clockView.color = MAIN_YELLOW_COLOR;
        
        [user.lates enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
            RMLate *late = (RMLate *)obj;
            
            NSString *start = [latesDateFormater stringFromDate:late.start];
            NSString *stop = [latesDateFormater stringFromDate:late.stop];
            
            if (start.length || stop.length)
            {
                [hours appendFormat:@" %@ - %@", start.length ? start : @"...",
                 stop.length ? stop : @"..."];
            }
        }];
    }
    else if (user.absences.count)
    {
        cell.clockView.color = MAIN_RED_COLOR;
        
        [user.absences enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
            RMAbsence *absence = (RMAbsence *)obj;

            NSString *start = [absenceDateFormater stringFromDate:absence.start];
            NSString *stop = [absenceDateFormater stringFromDate:absence.stop];
            
            if (start.length || stop.length)
            {
                [hours appendFormat:@" %@  -  %@", start.length ? start : @"...",
                 stop.length ? stop : @"..."];
            }
        }];
    }
    
    while ([hours hasPrefix:@" "])
    {
        [hours replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
    }
    
    cell.warningDateLabel.text = hours;
    
    if (user.avatarURL)
    {
        [cell.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:user.avatarURL]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableView.rowHeight;
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[UserDetailsTableViewController class]])
    {
        UserListCell *cell = (UserListCell *)sender;
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        
        if (indexPath == nil)
        {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
        }
        
        currentIndexPath = indexPath;
        
        ((UserDetailsTableViewController *)segue.destinationViewController).user = _userList[indexPath.row];
    }
    else if ([segue.identifier isEqualToString:@"FilterSegue"])
    {        
        ((FilterViewController *)(((UINavigationController *)segue.destinationViewController).visibleViewController)).filterStructure = self.filterStructure;
        [((FilterViewController *)(((UINavigationController *)segue.destinationViewController).visibleViewController)) setFilterSelection:self.filterSelections];
        ((FilterViewController *)(((UINavigationController *)segue.destinationViewController).visibleViewController)).delegate = self;
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

#pragma mark - Keyboard management
/*
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (!keyboardVisible)
    {
        [self updateTableForKeyboardVisible:YES keyboardInfo:notification.userInfo];
    }
    
    keyboardVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (keyboardVisible)
    {
        [self updateTableForKeyboardVisible:NO keyboardInfo:notification.userInfo];
    }
    
    keyboardVisible = NO;
}

- (void)updateTableForKeyboardVisible:(BOOL)visible keyboardInfo:(NSDictionary *)info
{
    CGRect keyboardBounds = CGRectZero;
    
    [[info valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    CGFloat keyboardHeight = keyboardBounds.size.height;
    
    NSTimeInterval duration = 0.0;
    [[info valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    
    [UIView animateWithDuration:duration animations:^{
        CGFloat offset = iOS7_PLUS ? 0.0f : -tabBarHeight;
        self.tableViewBottomConstraint.constant = visible ? (keyboardHeight + offset): 0.0f;
        [_tableView layoutIfNeeded];
    } completion:nil];
}
*/
@end