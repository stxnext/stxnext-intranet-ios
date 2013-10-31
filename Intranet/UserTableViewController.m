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
    STXSortingTypeFreelancers
}STXSortingType;

@interface UserTableViewController ()
{
    BOOL usersDownloaded;
}

@end

@implementation UserTableViewController
{
    STXSortingType currentSortType;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    usersDownloaded = NO;
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Odśwież"];
    [refresh addTarget:self action:@selector(startRefreshData)forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    _userList = [NSArray array];
    _fullUserList = [NSArray array];
    [self.tableView hideEmptySeparators];
    self.title = @"Lista";
    currentSortType = STXSortingTypeWorkers;
    
     [self loadUsersFromDatabase];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![[HTTPClient sharedClient] authCookiesPresent])
    {
        [self showLoginScreen];
    }
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
    [self loadUsersFromAPI];
}

- (void)stopRefreshData
{
    [self.refreshControl endRefreshing];
}

- (void)loadUsers
{
    // First try to load from CoreData
    [self loadUsersFromDatabase];
    
    // If there are no users in CoreData, load from API
    if (!_userList || _userList.count == 0)
        [self loadUsersFromAPI];
    
    // Refresh GUI
    [self.tableView reloadData];
    [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
}

- (void)loadUsersFromDatabase
{
    NSLog(@"Loading from: Database");
    _fullUserList = [JSONSerializationHelper objectsWithClass:[RMUser class]
                                       withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                            withPredicate:nil
                                         inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
    
    NSLog(@"Loaded: %d", _fullUserList.count);
    [self showUserWithType:STXSortingTypeWorkers];
}

- (void)loadUsersFromAPI
{
    NSLog(@"Loading from: API");
    [[HTTPClient sharedClient] startOperation:[APIRequest getUsers]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          // Delete from database
                                          [JSONSerializationHelper deleteObjectsWithClass:[RMUser class]
                                                                         inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                                          
                                          // Add to database
                                          for (id user in responseObject[@"users"])
                                              [RMUser mapFromJSON:user];
                                          
                                          // Load from database
                                          NSMutableArray* users = [NSMutableArray array];
                                          
                                          NSArray* allUsers = [JSONSerializationHelper objectsWithClass:[RMUser class]
                                                                 withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                                                      withPredicate:nil
                                                                   inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
                                          
                                          for (RMUser* user in allUsers)
                                          {
                                              [users addObject:user];
                                          }
                                          
                                          _fullUserList = users;
                                          
                                          [self showUserWithType:currentSortType];
                                          [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSLog(@"Loaded: 0");
                                          [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                          
                                          if ([operation redirectToLoginView])
                                          {
                                              [self showLoginScreen];
                                          }
                                      }];
    /*
     [[HTTPClient sharedClient] startOperation:[APIRequest getPresence]
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
     //NSLog(@"%@", responseObject);return;
     NSMutableArray* absences = [NSMutableArray array];
     
     for (id absence in responseObject[@"absences"])
     [absences addObject:[RMAbsence mapFromJSON:absence]];
     
     NSMutableArray* lates = [NSMutableArray array];
     
     for (id late in responseObject[@"lates"])
     [lates addObject:[RMLate mapFromJSON:late]];
     
     NSLog(@"Absences: %@\nLates: %@", absences, lates);
     NSLog(@"%@", ((RMAbsence*)absences.lastObject).user.name);
     }
     failure:nil];
     */
}

- (IBAction)showAction:(id)sender
{
    UIActionSheet *actionSheet  = [UIActionSheet SH_actionSheetWithTitle:nil buttonTitles:@[@"pracownicy", @"klienci", @"freelancers" ,@"", @"obecni", @"nieobecni"] cancelTitle:@"Anuluj" destructiveTitle:nil withBlock:^(NSInteger theButtonIndex) {
        switch (theButtonIndex)
        {
            case 0:
            {
                [self showUserWithType:STXSortingTypeWorkers];
            }
                break;
                
            case 1:
            {
                [self showUserWithType:STXSortingTypeClients];
            }
                break;
                
            case 2:
            {
                [self showUserWithType:STXSortingTypeFreelancers];
            }
                break;
        }
    }];
    
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)showUserWithType:(STXSortingType)type
{
    currentSortType = type;
    
    switch (currentSortType)
    {
        case STXSortingTypeAll:
        {
            
        }
            break;

        case STXSortingTypeWorkers:
        {
            [self showWorkers];
        }
            break;
            
        case STXSortingTypeClients:
        {
            [self showClients];
        }
            break;
            
        case STXSortingTypeFreelancers:
        {
            [self showFreelancers];
        }
            break;

    }
}

- (void)showWorkers
{
    NSMutableArray *users = [NSMutableArray array];

    for (RMUser *user in _fullUserList)
    {
        if ([user.isFreelancer boolValue] == NO && [user.isClient boolValue] == NO)
        {
            [users addObject:user];
        }
    }
    
    _userList = users;
    
    [self.tableView reloadData];
}

- (void)showClients
{
    NSMutableArray *users = [NSMutableArray array];
    
    for (RMUser *user in _fullUserList)
    {
        if ([user.isClient boolValue])
        {
            [users addObject:user];
        }
    }
    
    _userList = users;
    
    [self.tableView reloadData];
}
- (void)showFreelancers
{
    NSMutableArray *users = [NSMutableArray array];
    
    for (RMUser *user in _fullUserList)
    {
        if ([user.isFreelancer boolValue])
        {
            [users addObject:user];
        }
    }
    
    _userList = users;
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMUser* user = _userList[indexPath.row];
    
//    NSLog(@"%@", user);
    
    static NSString *CellIdentifier = @"UserCell";
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.userName.text = user.name;
    cell.userImage.layer.cornerRadius = 5;
    cell.userImage.clipsToBounds = YES;
    
    if (user.avatarURL)
        [cell.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:user.avatarURL]];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[UserDetailsTableViewController class]])
    {
        UserListCell *cell = (UserListCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        ((UserDetailsTableViewController *)segue.destinationViewController).user = _userList[indexPath.row];
    }
}

#pragma mark - Utilities

- (void)setImageForUrl:(NSString *)urlStr cell:(UserListCell *)cell
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [[HTTPClient sharedClient] addAuthCookiesToRequest:request];
    [cell.userImage setImageWithURLRequest:request placeholderImage:nil success:nil failure:nil];
}


@end