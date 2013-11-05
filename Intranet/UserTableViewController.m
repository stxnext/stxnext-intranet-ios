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

@interface UserTableViewController ()
{
    BOOL usersDownloaded;
}

@end

@implementation UserTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    usersDownloaded = NO;
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Odśwież"];
    [refresh addTarget:self action:@selector(startRefreshData)forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    _userList = [NSArray array];
    self.title = @"Lista osób";
    
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
    
    NSArray* users = [JSONSerializationHelper objectsWithClass:[RMUser class]
                                               withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]
                                                    withPredicate:nil
                                                 inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
    
    _userList = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClient = NO AND isFreelancer = NO"]];
    
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
    
    [self.tableView reloadData];
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
                                          
                                          // Load from database
                                          [self loadUsersFromDatabase];
                                          
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
                                          
                                          NSLog(@"Loaded: absences and lates");
                                          
                                          // Load from database
                                          [self loadUsersFromDatabase];
                                          
                                          if (--operations == 0)
                                              [self performSelector:@selector(stopRefreshData) withObject:nil afterDelay:0.5];
                                      }
                                      failure:nil];
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
    cell.warningImage.hidden = ((user.lates.count + user.absences.count) == 0);
    
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

@end