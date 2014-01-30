//
//  UserTableViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "FilterViewController.h"

@interface UserTableViewController : UIViewController<LoginViewControllerDelegate,
                                                    UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FilterViewControllerDelegate>
{
    IBOutlet UITableView* _tableView;
    IBOutlet UISearchBar* _searchBar;
    IBOutlet UIBarButtonItem *_showSearchButton;
    IBOutlet UIBarButtonItem *_showActionButton;

    UIRefreshControl* _refreshControl;
    UIActionSheet* _actionSheet;
    NSArray* _userList;
    UIActionSheet *actionSheet;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

@property (strong, nonatomic) NSMutableArray *filterStructure;
@property (strong, nonatomic) NSMutableArray *filterSelections;

- (IBAction)showSearch;
- (IBAction)showAction:(id)sender;

@end
