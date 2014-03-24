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

@interface UsersTableViewController : UITableViewController <LoginViewControllerDelegate, UISearchBarDelegate, FilterViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *_tableView;
    IBOutlet UIBarButtonItem *_showActionButton;
    __weak IBOutlet UIBarButtonItem *_showPlanningPokerButton;
    
    NSArray *_userList;
    UIActionSheet *actionSheet;
}

@property (strong, nonatomic) NSMutableArray *filterStructure;
@property (strong, nonatomic) NSMutableArray *filterSelections;

- (IBAction)showPlaningPoker:(id)sender;

@end
