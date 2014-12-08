//
//  ListTableViewController.m
//  Intranet
//
//  Created by Adam on 28.11.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "ListTableViewController.h"

@interface ListTableViewController ()

@end

@implementation ListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
 
    [self.tableView hideEmptySeparators];
    [self.searchDisplayController.searchResultsTableView hideEmptySeparators];
    
    currentListState = [self nextListState];
    [self showOutViewButton];
    [self addRefreshControl];
}

- (void)hideOutViewButton
{
    [self performBlockOnMainThread:^{
        self.viewSwitchButton.enabled = NO;
        [self.navigationItem setLeftBarButtonItem:self.viewSwitchButton animated:YES];
    } afterDelay:0];
}

- (IBAction)changeView:(id)sender
{
    currentListState = [self nextListState];
    [self showOutViewButton];
    [self loadUsersFromDatabase];

    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [self showNoSelectionUserDetails];
}

- (ListState)nextListState
{
    NSAssert(NO, @"Subclasses need to overwrite this method");
    return ListStateNotSet;
}

- (void)showOutViewButton
{
    NSAssert(NO, @"Subclasses need to overwrite this method");
}

#pragma mark - Data

- (void)processUsers:(NSDictionary *)users absencesAndLates:(NSDictionary *)absencesAndLates finalAction:(SimpleBlock)finalAction
{
    //    [[NSOperationQueue new] addOperationWithBlock:^{
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
        if (users)
        {
            [JSONSerializationHelper deleteObjectsWithClass:[RMUser class]
                                           inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
        }
        
        if (absencesAndLates)
        {
            [JSONSerializationHelper deleteObjectsWithClass:[RMAbsence class]
                                           inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
            
            [JSONSerializationHelper deleteObjectsWithClass:[RMLate class]
                                           inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
        }
        
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
                
                if (finalAction)
                {
                    finalAction();
                }
            }
        }];
    }
    //    }];
}

- (void)downloadUsers:(void (^)(NSDictionary *users))resultAction
{
    [[HTTPClient sharedClient] startOperation:[RMUser userLoggedType] == UserLoginTypeTrue ? [APIRequest getUsers] : [APIRequest getFalseUsers]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSLog(@"Loaded: users");
                                          resultAction(responseObject);
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          
                                          NSLog(@"Users API Loading Error");
                                          
                                          if ([operation redirectToLoginView])
                                          {
                                              [self showLoginScreen];
                                          }
                                          
                                          [self.tableView reloadData];
                                          
                                          [[HTTPClient sharedClient].operationQueue cancelAllOperations];
                                          
                                          resultAction(nil);
                                          
                                          [self informStopDownloading];
                                      }];
    
}

- (void)downloadAbsencesAndLates:(void (^)(NSDictionary *absencesAndLates))resultAction
{
    [[HTTPClient sharedClient] startOperation:[RMUser userLoggedType] == UserLoginTypeTrue ? [APIRequest getPresence] : [APIRequest getFalsePresence]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSLog(@"Loaded: absences and lates");
                                          resultAction(responseObject);
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          
                                          NSLog(@"Presence API Loading Error");
                                          
                                          [[HTTPClient sharedClient].operationQueue cancelAllOperations];
                                          
                                          resultAction(nil);
                                          
                                          [self informStopDownloading];
                                      }];
}

- (void)loadUsersFromAPI:(SimpleBlock)finalAction
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
        
        finalAction();
        
        return;
    }
    
    NSLog(@"Start loading from: API");
    
    [self informStartDownloading];
    NSMutableDictionary *downloadedData = [NSMutableDictionary new];
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.suspended = YES;
    
    __block ControllableBlock *getUsers;
    getUsers = [ControllableBlock blockOperationWithBlock:^{
        NSLog(@"Block - Get users");
        [self downloadUsers:^(NSDictionary *users) {
            if (users)
            {
                [downloadedData setObject:users forKey:@"users"];
            }
            
            [getUsers informIsFinished];
        }];
    }];
    
    __block ControllableBlock *getAbsencesAndLates;
    getAbsencesAndLates = [ControllableBlock blockOperationWithBlock:^{
        NSLog(@"Block - Get Absences And Lates");
        [self downloadAbsencesAndLates:^(NSDictionary *absencesAndLates) {
            if (absencesAndLates)
            {
                [downloadedData setObject:absencesAndLates forKey:@"absencesAndLates"];
            }
            
            [getAbsencesAndLates informIsFinished];
        }];
    }];
    
    NSBlockOperation *processData = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Block - Process Data");
        [self processUsers:[downloadedData objectForKey:@"users"] absencesAndLates:[downloadedData objectForKey:@"absencesAndLates"] finalAction:finalAction];
    }];
    
    [processData addDependency:getUsers];
    [processData addDependency:getAbsencesAndLates];
    
    [queue addOperations:@[getUsers, getAbsencesAndLates, processData] waitUntilFinished:NO];
    queue.suspended = NO;
}

- (void)reloadLates:(SimpleBlock)finalAction
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
        
        finalAction();
        
        return;
    }
    
    NSLog(@"Start loading from: reload Lates");
    
    [self informStartDownloading];
    NSMutableDictionary *downloadedData = [NSMutableDictionary new];
    NSOperationQueue *queue = [NSOperationQueue new];
    queue.suspended = YES;
    
    __block ControllableBlock *getAbsencesAndLates;
    getAbsencesAndLates = [ControllableBlock blockOperationWithBlock:^{
        NSLog(@"Block - Get Absences And Lates");
        [self downloadAbsencesAndLates:^(NSDictionary *absencesAndLates) {
            if (absencesAndLates)
            {
                [downloadedData setObject:absencesAndLates forKey:@"absencesAndLates"];
            }
            
            [getAbsencesAndLates informIsFinished];
        }];
    }];
    
    NSBlockOperation *processData = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Block - Process Data");
        [self processUsers:[downloadedData objectForKey:@"users"] absencesAndLates:[downloadedData objectForKey:@"absencesAndLates"] finalAction:finalAction];
    }];
    
    [processData addDependency:getAbsencesAndLates];
    
    [queue addOperations:@[getAbsencesAndLates, processData] waitUntilFinished:NO];
    queue.suspended = NO;
}

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
                userList = [NSMutableArray arrayWithArray:[self.allUsers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
            }
            else
            {
                userList = [NSMutableArray arrayWithArray:self.allUsers];
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
                userList = [NSMutableArray arrayWithCapacity:3];
                userList[0] = [NSMutableArray arrayWithArray:[self.todayOutOffOfficePeople[0] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
                userList[1] = [NSMutableArray arrayWithArray:[self.todayOutOffOfficePeople[1] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
                userList[2] = [NSMutableArray arrayWithArray:[self.todayOutOffOfficePeople[2] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
            }
            else
            {
                userList = [NSMutableArray arrayWithArray:self.todayOutOffOfficePeople];
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
                userList = [NSMutableArray arrayWithCapacity:3];
                userList[0] = [NSMutableArray arrayWithArray:[self.tomorrowOutOffOfficePeople[0] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
                userList[1] = [NSMutableArray arrayWithArray:[self.tomorrowOutOffOfficePeople[1] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
                userList[2] = [NSMutableArray arrayWithArray:[self.tomorrowOutOffOfficePeople[2] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
            }
            else
            {
                userList = [NSMutableArray arrayWithArray:self.tomorrowOutOffOfficePeople];
            }
            
        }
            break;
            
        default: break;
    }
    
    if (searchedString.length > 0)
    {
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else
    {
        [self.tableView reloadData];
    }
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
    IBOutlet UIBarButtonItem *_showActionButton;

- (void)stopRefreshData
{
    [_refreshControl endRefreshing];
    
    _showActionButton.enabled = YES;
    isUpdating = NO;
}

#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserCell";
    
    UserListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RMUser *user;
    NSInteger realSection = [self realSectionForNotEmptySection:indexPath.section];

    if (currentListState == ListStateAll)
    {
        user = userList[indexPath.row];
    }
    else
    {
        user = userList[realSection][indexPath.row];
    }
    
    cell.userName.text = user.name;
    
    [cell.userImage makeRadius:5 borderWidth:1 color:[UIColor grayColor]];
    
    if (!isDatabaseBusy)
    {
        __block BOOL shouldHiddeClock = YES;
        cell.clockView.hidden = shouldHiddeClock;
        
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
                    shouldHiddeClock = NO;
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
                    shouldHiddeClock = NO;
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
            if (realSection == 1 || realSection == 2)
            {
                setLates();
            }
            else if (realSection == 0)
            {
                setAbsences();
            }
        }
        
        [hours setString:[hours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        cell.clockView.hidden = shouldHiddeClock;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number;
    NSInteger count = 1;
    
    if (currentListState == ListStateAll)
    {
        number = userList.count;
    }
    else
    {
        number = [userList[section] count];
        count = [userList[0] count] + [userList[1] count] + [userList[2] count];
    }
    
    if (count == 0 && section == 0 && canShowNoResultsMessage)//show once
    {
        [UIAlertView showWithTitle:@"Info"
                           message:@"Nothing to show."
                             style:UIAlertViewStyleDefault
                 cancelButtonTitle:nil
                 otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                 }];
    }
    
    if (number)
    {
        canShowNoResultsMessage = NO;
    }
    
    return number;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (currentListState == ListStateAll)
    {
        return 1;
    }
    else
    {
        return [self numberOfNotEmptySections];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (currentListState != ListStateAll)
    {
        NSInteger realSection = [self realSectionForNotEmptySection:section];
        
        switch (realSection)
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.rowHeight;
}

- (NSInteger)realSectionForNotEmptySection:(NSInteger)section
{
    if (currentListState == ListStateAll)
    {
        return section;
    }
    
    NSInteger result = -1;
    
    for (NSArray *array in userList)
    {
        result++;
        [array count] ? section--: section;

        if (section < 0)
            break;
    }
 
    return result;
}

- (NSInteger)fakeSectionForRealSection:(NSInteger)section
{
    NSInteger result = -1;
    
    if (currentListState == ListStateAll)
    {
        return section;
    }
    
    int idx = 0;
    for (NSArray *array in userList)
    {
        [array count] ? result++: result;
        
        if (idx == section)
        {
            break;
        }
        
        idx++;
    }
    
    return result;
}

- (NSInteger)numberOfNotEmptySections
{
    int result = 0;
    
    for (NSArray *array in userList)
    {
        [array count]  ? result++ : result;
    }
 
    return result;
}

#pragma mark - UISearchController

- (void)reloadSearchWithText:(NSString *)text
{
    canShowNoResultsMessage = NO;
    [self showNoSelectionUserDetails];
    searchedString = text;
    
    [self loadUsersFromDatabase];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self reloadSearchWithText:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self reloadSearchWithText:@""];
}

- (IBAction)showNewRequest:(id)sender
{
    if (![[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Internet connection." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else
    {
        if (INTERFACE_IS_PHONE)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"New request" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Absence / Holiday", @"Out of office", nil];
            
            [actionSheet showFromTabBar:self.tabBarController.tabBar];

        }
        else
        {
            [self.requestActionSheet dismissWithClickedButtonIndex:20 animated:NO];
            [self.popover dismissPopoverAnimated:NO];
            
            self.requestActionSheet = [[UIActionSheet alloc] initWithTitle:@"New request" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Absence / Holiday", @"Out of office", nil];

            
            [self.requestActionSheet showFromBarButtonItem:self.addRequestButton animated:YES];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < 2)
    {
        if (INTERFACE_IS_PHONE)
        {
            UINavigationController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddOOOFormTableViewControllerId"];
            
            [self presentViewController:nvc animated:YES completion:nil];
            
            AddOOOFormTableViewController *form = [nvc.viewControllers firstObject];
            form.currentRequest = (int)buttonIndex;
            form.delegate = self;
        }
        else
        {
            UINavigationController *nvc = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"AddOOOFormTableViewControllerId"];
            
            AddOOOFormTableViewController *outOfOfficeForm = [nvc.viewControllers firstObject];
            outOfOfficeForm.currentRequest = (int)buttonIndex;
            outOfOfficeForm.delegate = self;
            
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
}

#pragma mark - Storyboard

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"AddOOOFormTableViewControllerId"] && ![[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        [UIAlertView showWithTitle:@"Error"
                           message:@"No Internet connection."
                             style:UIAlertViewStyleDefault
                 cancelButtonTitle:nil
                 otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                 }];
        
        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[UserDetailsTableViewController class]])
    {
        UserDetailsTableViewController *viewController = (UserDetailsTableViewController *)segue.destinationViewController;
        
        UserListCell *cell = (UserListCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        if (indexPath == nil)
        {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
        }
        
        if (currentListState == ListStateAll)
        {
            viewController.user = userList[indexPath.row];
        }
        else
        {
            NSInteger realSection = [self realSectionForNotEmptySection:indexPath.section];
            
            if (realSection == 0)
            {
                viewController.isComeFromAbsences = YES;
            }
            
            viewController.user = userList[realSection][indexPath.row];
        }
        
        viewController.isListStateTommorow = currentListState == ListStateOutTomorrow;
        
        if (INTERFACE_IS_PAD)
        {
            viewController.delegate = self;
        }
    }
}

#pragma mark - AddOOOFormTableViewControllerDelegate

- (void)didFinishAddingOOO
{
    [self reloadLates:^{
        [self stopRefreshData];
    }];
}

#pragma mark - UserDetailsTableViewControllerDelegate

- (void)didChangeUserDetailsToMe
{
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
    RMUser *me = [RMUser me];
    
    NSInteger __block position = NSNotFound;
    NSInteger __block  section = 0;
    
    switch (currentListState)
    {
        case ListStateNotSet:
            return;

        case ListStateAll:
            position = [userList indexOfObject:me];
            break;

        case ListStateOutToday:
        case ListStateOutTomorrow:
            [userList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj containsObject:me])
                {
                    position = [obj indexOfObject:me];
                    section = [self fakeSectionForRealSection:idx];
                    *stop = YES;
                }
            }];
            
            break;
    }

    if (position != NSNotFound)
    {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:position inSection:section]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionTop];
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

#pragma mark - iPad

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

@end
