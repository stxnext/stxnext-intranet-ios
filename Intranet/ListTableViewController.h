//
//  ListTableViewController.h
//  Intranet
//
//  Created by Adam on 28.11.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserListCell.h"
#import "UserDetailsTableViewController.h"
#import "AddOOOFormTableViewController.h"
#import "UIImageView+Additions.h"
#import "APIRequest.h"
#import "AFHTTPRequestOperation+Redirect.h"
#import "ControllableBlock.h"

typedef NS_ENUM(NSUInteger, ListState) {
    ListStateNotSet, 
    ListStateAll,
    ListStateOutToday,
    ListStateOutTomorrow,
};

@interface ListTableViewController : UITableViewController <UISearchBarDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, UserDetailsTableViewControllerDelegate, AddOOOFormTableViewControllerDelegate>
{
    NSString *searchedString;
    ListState currentListState;
    NSMutableArray *userList;
    NSMutableArray *avatarsToRefresh;
//    UIRefreshControl *_refreshControl;
    BOOL canShowNoResultsMessage;
    BOOL isDatabaseBusy;
    BOOL shouldReloadAvatars;
    BOOL isUpdating;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *viewSwitchButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addRequestButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *showActionButton;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) UIActionSheet *requestActionSheet;

@property (strong, nonatomic) NSArray *allUsers;
@property (strong, nonatomic) NSArray *outOfOfficePeople;

- (void)hideOutViewButton;
- (void)loadUsersFromDatabase;
- (void)showNoSelectionUserDetails;
- (void)showLoginScreen;
- (void)addRefreshControl;
- (void)stopRefreshData;

- (ListState)nextListState;
- (void)showOutViewButton;
- (IBAction)changeView:(id)sender;
- (IBAction)showNewRequest:(id)sender;
- (void)loadUsersFromAPI:(SimpleBlock)finalAction;
- (void)reloadLates:(SimpleBlock)finalAction;

@end
