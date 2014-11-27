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
#import "UserListCell.h"
#import "UserDetailsTableViewController.h"
#import "PlaningPokerViewController.h"
#import "UIView+Screenshot.h"
#import "AppDelegate+Settings.h"
#import "AddOOOFormTableViewController.h"

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
    BOOL isOutView;
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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refresh"];
    [refreshControl addTarget:self action:@selector(startRefreshData)forControlEvents:UIControlEventValueChanged];
    _refreshControl = refreshControl;
    self.refreshControl = refreshControl;
    
    [_tableView hideEmptySeparators];
    [self.searchDisplayController.searchResultsTableView hideEmptySeparators];
    
    isOutView = NO;
    [self.viewSwitchButton setTitle:@"Out"];
    self.title = @"All";
    
    //update data
    if ([APP_DELEGATE userLoggedType] != UserLoginTypeNO)
    {
        [self loadUsersFromDatabase];

        [self performBlockInCurrentThread:^{
            [self loadUsersFromAPI];
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

- (IBAction)changeView:(id)sender
{
    isOutView = !isOutView;
    
    if (isOutView)
    {
        [self.viewSwitchButton setTitle:@"All"];
        self.title = @"Out";
    }
    else
    {
        [self.viewSwitchButton setTitle:@"Out"];
        self.title = @"All";
    }
    
    [self loadUsersFromDatabase];
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
                                              
                                              [self loadUsersFromAPI];
                                          }
                                          else
                                          {
                                              //error with login (e.g. account not exists)
                                              [APP_DELEGATE setUserLoggedType:UserLoginTypeFalse];
                                              
                                              [[self.tabBarController.tabBar.items lastObject] setTitle:@"About"];
                                              
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
    
    shouldReloadAvatars = YES;
}

- (void)stopRefreshData
{
    [_refreshControl endRefreshing];
    
    _showActionButton.enabled = YES;
    _showPlanningPokerButton.enabled = YES;
}

#pragma mark - LoadUsers

- (void)loadUsersFromDatabase
{
    if (isOutView)
    {
        _userList = [RMUser loadOutOffOfficePeople];
        
        if (searchedString.length > 0)
        {
            [_userList replaceObjectAtIndex:0 withObject:[NSMutableArray arrayWithArray:[_userList[0] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]]];
            [_userList replaceObjectAtIndex:1 withObject:[NSMutableArray arrayWithArray:[_userList[1] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]]];
            [_userList replaceObjectAtIndex:2 withObject:[NSMutableArray arrayWithArray:[_userList[2] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]]];
        }
    }
    else
    {
        NSArray *users = [JSONSerializationHelper objectsWithClass:[RMUser class]
                                                withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                                 ascending:YES
                                                                                                  selector:@selector(localizedCompare:)]
                                                     withPredicate:[NSPredicate predicateWithFormat:@"isActive = YES"]
                                                  inManagedContext:[DatabaseManager sharedManager].managedObjectContext];

        _userList = [NSMutableArray arrayWithArray:[users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClient = NO AND isFreelancer = NO"]]];
    
        if (searchedString.length > 0)
        {
            _userList = [NSMutableArray arrayWithArray:[_userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
        }
    }
    
    NSLog(@"Loading from: Database: %lu", (unsigned long)_userList.count);

    if (searchedString.length > 0)
    {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else
    {
        [_tableView reloadData];
    }
}

BOOL isDatabaseBusy;

- (void)loadUsersFromAPI
{
    isDatabaseBusy = NO;
    self.viewSwitchButton.enabled = YES;
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        NSLog(@"No internet");
        [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];

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
            self.viewSwitchButton.enabled = NO;
            
            if (shouldReloadAvatars)
            {
                avatarsToRefresh = [NSMutableArray new];
                
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
                    [RMAbsence mapFromJSON:absence];
                }
                
                for (id late in absencesAndLates[@"lates"])
                {
                    [RMLate mapFromJSON:late];
                }
                
                
//                for (id absence in absencesAndLates[@"absences_tomorrow"])
//                {
//                    [RMAbsence mapFromJSON:absence];
//                }
//                
//                for (id late in absencesAndLates[@"lates_tomorrow"])
//                {
//                    [RMLate mapFromJSON:late];
//                }

                [[DatabaseManager sharedManager] saveContext];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    @synchronized(self){
                        [self loadUsersFromDatabase];
                        [self informStopDownloading];
                        
                        isDatabaseBusy = NO;
                        self.viewSwitchButton.enabled = YES;
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
                                              
                                              [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          
                                          NSLog(@"Users API Loading Error");
                                          [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                          
                                          if ([operation redirectToLoginView])
                                          {
                                              [self showLoginScreen];
                                          }
                                          
                                          [self.tableView reloadData];
                                          
                                          [[HTTPClient sharedClient].operationQueue cancelAllOperations];
                                          
                                          [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                          
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
                                              
                                              [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          
                                          NSLog(@"Presence API Loading Error");

                                          [[HTTPClient sharedClient].operationQueue cancelAllOperations];
                                          
                                          [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                          
                                          [self informStopDownloading];
                                      }];
}

#pragma mark - Filter delegate

- (void)changeFilterSelections:(NSArray *)filterSelection
{
    canShowNoResultsMessage = YES;
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isOutView)
    {
        return [_userList count];
    }
    else
    {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number;
    
    if (isOutView)
    {
        number = [_userList[section] count];
    }
    else
    {
        number = _userList.count;
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
    
    NSLog(@"%@", tableView);
    
    UserListCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    RMUser *user;
    
    if (isOutView)
    {
        user = _userList[indexPath.section][indexPath.row];
    }
    else
    {
        user = _userList[indexPath.row];
    }
    
    cell.userName.text = user.name;
    
    cell.userImage.layer.cornerRadius = 5;
    cell.userImage.clipsToBounds = YES;
    cell.userImage.layer.borderColor = [[UIColor grayColor] CGColor];
    cell.userImage.layer.borderWidth = 1;
    
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
                
                NSString *start = [absenceDateFormater stringFromDate:absence.start];
                NSString *stop = [absenceDateFormater stringFromDate:absence.stop];
                
                if (start.length || stop.length)
                {
                    [hours appendFormat:@" %@  -  %@\n", start.length ? start : @"...",
                     stop.length ? stop : @"..."];
                }
            }];
            
        };
        
        void(^setLates)(void) = ^(void) {
            cell.clockView.color = MAIN_YELLOW_COLOR;
            
            [user.lates enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
                RMLate *late = (RMLate *)obj;
                
                NSString *start = [latesDateFormater stringFromDate:late.start];
                NSString *stop = [latesDateFormater stringFromDate:late.stop];
                
                if (start.length || stop.length)
                {
                    [hours appendFormat:@" %@ - %@\n", start.length ? start : @"...",
                     stop.length ? stop : @"..."];
                }
            }];
        };
        
        if (isOutView)
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
        else
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

        [hours setString:[hours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];

        cell.warningDateLabel.text = hours;
    }
    
    if (user.avatarURL)
    {
        BOOL refresh = [avatarsToRefresh containsObject:user.id];
        [cell.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:user.avatarURL] forceRefresh:refresh];
        
        if (refresh)
        {
            [avatarsToRefresh removeObject:user.id];
        }
    }
        
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableView.rowHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (isOutView)
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
        
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        
        if (indexPath == nil)
        {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
        }
        
        currentIndexPath = indexPath;
        
        if (isOutView)
        {
            if (indexPath.section == 0)
            {
                ((UserDetailsTableViewController *)segue.destinationViewController).isComeFromAbsences = YES;
            }
            
            ((UserDetailsTableViewController *)segue.destinationViewController).user = _userList[indexPath.section][indexPath.row];
        }
        else
        {
            ((UserDetailsTableViewController *)segue.destinationViewController).user = _userList[indexPath.row];
        }
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

@end
