//
//  UserTableViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface UserListTableViewController : UITableViewController <LoginViewControllerDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate>
{
    IBOutlet UITableView *_tableView;
    IBOutlet UIBarButtonItem *_showActionButton;
    __weak IBOutlet UIBarButtonItem *_showPlanningPokerButton;
    
    UIRefreshControl *_refreshControl;
    UIActionSheet  *_actionSheet;
    NSMutableArray *_userList;
    UIActionSheet *actionSheet;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addRequestButton;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) UIActionSheet *requestActionSheet;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *viewSwitchButton;

- (IBAction)showPlaningPoker:(id)sender;
- (IBAction)changeView:(id)sender;

@end
