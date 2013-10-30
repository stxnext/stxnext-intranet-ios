//
//  UserTableViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UserTableViewController.h"
#import "APIMapping.h"
#import "APIRequest.h"
#import "UserListCell.h"
#import "UserDetailsTableViewController.h"

@implementation UserTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userList = [NSArray array];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Just a temporary one time dispatch
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Show sign in modal
        [LoginViewController presentAfterSetupWithDecorator:^(UIModalViewController *controller) {
            LoginViewController* customController = (LoginViewController*)controller;
            customController.delegate = self;
        }];
    });
}

#pragma mark Login delegate

- (void)finishedLoginWithCode:(NSString*)code withError:(NSError*)error
{
    // Assume success, use code to fetch cookies
    [[HTTPClient sharedClient] startOperation:[APIRequest loginWithCode:code]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          // We expect 302
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSArray* cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:operation.response.allHeaderFields forURL:operation.response.URL];
                                          
                                          // If redirected properly
                                          if (operation.response.statusCode == 302 && cookies)
                                          {
                                              [[HTTPClient sharedClient] startOperation:[APIRequest getUsers]
                                                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                    NSMutableArray* users = [NSMutableArray array];
                                                                                    
                                                                                    for (id user in responseObject[@"users"])
                                                                                        [users addObject:[RMUser mapFromJSON:user]];
                                                                                    
                                                                                    _userList = users;
                                                                                    [self.tableView reloadData];
                                                                                }
                                                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                    // Handle error
                                                                                }];
                                          }
                                      }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMUser* user = _userList[indexPath.row];
    
    NSLog(@"%@", user);
    
    static NSString *CellIdentifier = @"UserCell";
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.userName.text = user.name;
    [cell.userImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://intranet.stxnext.pl%@", user.avatarURL]] placeholderImage:nil];
    
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
