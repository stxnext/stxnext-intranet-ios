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

@interface UserTableViewController : UITableViewController<LoginViewControllerDelegate, UISearchBarDelegate, FilterViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *_tableView;
    IBOutlet UIBarButtonItem *_showActionButton;

    UIRefreshControl *_refreshControl;
    UIActionSheet  *_actionSheet;
    NSArray *_userList;
    UIActionSheet *actionSheet;
}
@property (strong, nonatomic)  UILabel *notFoundLabel;
@property (strong, nonatomic) NSMutableArray *filterStructure;
@property (strong, nonatomic) NSMutableArray *filterSelections;

@end
