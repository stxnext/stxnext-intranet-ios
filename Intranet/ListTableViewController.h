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

typedef NS_ENUM(NSUInteger, ListState) {
    ListStateNotSet, 
    ListStateAll,
    ListStateOutToday,
    ListStateOutTomorrow,
};

@interface ListTableViewController : UITableViewController <UISearchBarDelegate, UIActionSheetDelegate, UIPopoverControllerDelegate, UserDetailsTableViewControllerDelegate>
{
    NSString *searchedString;
    ListState currentListState;
    NSMutableArray *userList;
    NSMutableArray *avatarsToRefresh;
    BOOL canShowNoResultsMessage;
    BOOL isDatabaseBusy;
}

@property (weak, nonatomic) IBOutlet UIBarButtonItem *viewSwitchButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addRequestButton;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong, nonatomic) UIActionSheet *requestActionSheet;

@property (strong, nonatomic) NSArray *allUsers;
@property (strong, nonatomic) NSArray *todayOutOffOfficePeople;
@property (strong, nonatomic) NSArray *tomorrowOutOffOfficePeople;

- (void)hideOutViewButton;
- (void)loadUsersFromDatabase;
- (void)showNoSelectionUserDetails;

- (ListState)nextListState;
- (void)showOutViewButton;
- (IBAction)changeView:(id)sender;
- (IBAction)showNewRequest:(id)sender;

@end
