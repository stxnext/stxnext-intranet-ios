//
//  UserTableViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface UserTableViewController : UIViewController<LoginViewControllerDelegate,
                                                    UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    IBOutlet UITableView* _tableView;
    IBOutlet UISearchBar* _searchBar;

    UIRefreshControl* _refreshControl;
    UIActionSheet* _actionSheet;
    NSArray* _userList;
    UIActionSheet *actionSheet;
}

- (IBAction)showAction:(id)sender;

@end
