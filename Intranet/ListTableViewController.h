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
    ListStateAll,
    ListStateOutToday,
    ListStateOutTomorrow,
};

@interface ListTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *viewSwitchButton;


- (void)hideOutViewButton;

@end
