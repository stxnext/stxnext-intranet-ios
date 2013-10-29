//
//  UserTableViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UserTableViewController.h"

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
    [HTTPClient loadURLString:[NSString stringWithFormat:@"https://intranet.stxnext.pl/auth/callback?code=%@", code]
             withSuccessBlock:^(NSHTTPURLResponse *response, NSData *data) {
                 // Assume success, use cookies to fetch users
                 //NSLog(@"Cookies: %@", [NSHTTPCookie cookiesWithResponseHeaderFields:response.allHeaderFields forURL:response.URL]);
                 
                 [RKClient performRequest:[RKRequest users]
                         withSuccessBlock:^(NSArray *result) {
                             _userList = result;
                             [self.tableView reloadData];
                         }
                         withFailureBlock:^(NSError *error) {
                         }];
             }
             withFailureBlock:^(NSHTTPURLResponse *response, NSError *error) {
                 
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
    
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = user.name;
    
    return cell;
}

@end
