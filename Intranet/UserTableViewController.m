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

typedef enum
{
    STXSortingTypeAll,
    STXSortingTypeWorkers,
    STXSortingTypeClients,
    STXSortingTypeFreelancers,
    STXSortingTypeAbsent,
    STXSortingTypeLate
} STXSortingType;

static CGFloat statusBarHeight;
static CGFloat navBarHeight;
static CGFloat tabBarHeight;

@implementation UserTableViewController
{
    STXSortingType currentSortType;
    NSString* searchedString;
    NSIndexPath* currentIndexPath;
    
    BOOL keyboardVisible;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    navBarHeight = self.navigationController.navigationBar.frame.size.height;
    tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    
    keyboardVisible = NO;
    
    [self updateGuiForBarState:NO];
    
    searchedString = @"";
    _actionSheet = nil;
    _userList = [NSArray array];
    currentSortType = STXSortingTypeWorkers;
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Odśwież"];
    [refresh addTarget:self action:@selector(startRefreshData)forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refresh];
    
    CGRect frame = refresh.frame;
    frame.origin.y = -frame.size.height;
    refresh.frame = frame;
    [_tableView sendSubviewToBack:refresh];
    
    _refreshControl = refresh;
    
    [_tableView hideEmptySeparators];
    self.title = @"Lista osób";
    
    [self loadUsersFromDatabase];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
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
    _showSearchButton.enabled = NO;
    _showActionButton.enabled = NO;
    [self loadUsersFromAPI];
}

- (void)stopRefreshData
{
    [_refreshControl endRefreshing];
    _showSearchButton.enabled = YES;
    _showActionButton.enabled = YES;
}

- (void)loadUsers
{
    // First try to load from CoreData
    [self loadUsersFromDatabase];
    
    // If there are no users in CoreData, load from API
    if (!_userList || _userList.count == 0)
        [self loadUsersFromAPI];
    
    // Refresh GUI
    [_tableView reloadData];
    [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
}

- (void)loadUsersFromDatabase
{
    NSLog(@"Loading from: Database");
    
    NSArray* users = [JSONSerializationHelper objectsWithClass:[RMUser class]
                                               withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                                    withPredicate:nil
                                                 inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
    
    switch (currentSortType)
    {
        case STXSortingTypeAll:
            _userList = users;
            break;
            
        case STXSortingTypeWorkers:
            _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClient = NO AND isFreelancer = NO"]];
            break;
            
        case STXSortingTypeClients:
            _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClient = YES"]];
            break;
            
        case STXSortingTypeFreelancers:
            _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isFreelancer = YES"]];
            break;
            
        case STXSortingTypeAbsent:
            _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"absences.@count = YES"]];
            break;
            
        case STXSortingTypeLate:
            _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lates.@count = YES"]];
            break;
    }
    
    if (searchedString.length > 0)
        _userList = [_userList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]];
    
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
    UIViewController* detailController = self.splitViewController.viewControllers.lastObject;
    
    if (![detailController isKindOfClass:[UINavigationController class]])
        return;
    
    UINavigationController* navigationController = (UINavigationController*)detailController;
    [navigationController setViewControllers:@[ [UIViewController new] ]];
}

- (void)loadUsersFromAPI
{
    __block NSInteger operations = 2;
    __block BOOL deletedUsers = NO;
    
    NSLog(@"Loading from: API");
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

- (IBAction)showAction:(id)sender
{
    if (!actionSheet.isVisible)
    {
        actionSheet  = [UIActionSheet SH_actionSheetWithTitle:nil buttonTitles:@[@"pracownicy", @"klienci", @"freelancers", @"", @"nieobecności", @"spóźnienia"] cancelTitle:@"Anuluj" destructiveTitle:nil withBlock:^(NSInteger theButtonIndex) {
            switch (theButtonIndex)
            {
                case 0: [self loadUsersFromDatabaseWithType:STXSortingTypeWorkers]; break;
                case 1: [self loadUsersFromDatabaseWithType:STXSortingTypeClients]; break;
                case 2: [self loadUsersFromDatabaseWithType:STXSortingTypeFreelancers]; break;
                case 3:  break;
                case 4: [self loadUsersFromDatabaseWithType:STXSortingTypeAbsent]; break;
                case 5: [self loadUsersFromDatabaseWithType:STXSortingTypeLate]; break;
            }
        }];

        [actionSheet showFromBarButtonItem:sender animated:YES];
    }
}

- (void)loadUsersFromDatabaseWithType:(STXSortingType)type
{
    currentSortType = type;
    
    [self loadUsersFromDatabase];
}

#pragma mark - Search management

- (IBAction)showSearch
{
    //_refreshControl.alpha = 0.0f;
    _showSearchButton.enabled = NO;
    [self showSearchBar:_searchBar animated:YES];
}

- (void)reloadSearchWithText:(NSString*)text
{
    searchedString = text;
    
    [self loadUsersFromDatabase];
}

- (void)updateGuiForBarState:(BOOL)barVisible
{
    CGRect barFrame = _searchBar.frame;
    CGRect tableFrame = _tableView.frame;
    
    barFrame.origin.y = iOS7_PLUS ? statusBarHeight + navBarHeight : 0.0f;
    
    if (!barVisible)
    {
        barFrame.origin.y -= barFrame.size.height;
    }
    
    tableFrame.origin.y = barFrame.origin.y + barFrame.size.height;
    tableFrame.size.height = self.view.frame.size.height - tableFrame.origin.y;
    
    if (iOS7_PLUS)
    {
        tableFrame.size.height -= tabBarHeight;
    }
    
    _searchBar.frame = barFrame;
    _tableView.frame = tableFrame;
}

- (void)showSearchBar:(UISearchBar *)searchBar animated:(BOOL)animated
{
    _searchBar.text = @"";
    [UIView animateWithDuration:0.33 animations:^{
        [self updateGuiForBarState:YES];
    }];
    
    double delayInSeconds = 0.33;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_searchBar becomeFirstResponder];
    });
}

- (void)hideSearchBar:(UISearchBar *)searchBar animated:(BOOL)animated
{
    [_searchBar resignFirstResponder];
    
    if (animated)
    {
        [UIView animateWithDuration:0.33 animations:^{
            [self updateGuiForBarState:NO];
        }];
    }
    else
    {
        [self updateGuiForBarState:NO];
    }
    
    double delayInSeconds = 0.33;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self reloadSearchWithText:@""];
    });
}

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self reloadSearchWithText:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self hideSearchBar:searchBar animated:YES];
    _showSearchButton.enabled = YES;
    //_refreshControl.alpha = 1.0f;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMUser* user = _userList[indexPath.row];
    
    static NSString *CellIdentifier = @"UserCell";
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
        [cell.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:user.avatarURL]];
    
    return cell;
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[UserDetailsTableViewController class]])
    {
        UserListCell *cell = (UserListCell *)sender;
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        currentIndexPath = indexPath;
        ((UserDetailsTableViewController *)segue.destinationViewController).user = _userList[indexPath.row];
    }
}

#pragma mark - Keyboard management

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
        CGRect frame = _tableView.frame;
        
        if (visible)
        {
            frame.size.height -= (keyboardHeight - tabBarHeight);
        }
        else
        {
            frame.size.height += (keyboardHeight - tabBarHeight);
        }
        _tableView.frame = frame;
    } completion:nil];
}

@end