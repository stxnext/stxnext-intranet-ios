//
//  TeamsTableViewController.h
//  Intranet
//
//  Created by Adam on 12.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TeamsTableViewControllerDelegate;
@interface TeamsTableViewController : UITableViewController

@property (strong, nonatomic) id<TeamsTableViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *previousSelectedUsers;
@property (nonatomic, strong) NSNumber *previousSelectedTeamId;

@end

@protocol TeamsTableViewControllerDelegate <NSObject>

- (void)teamsTableViewController:(TeamsTableViewController *)teamsTableViewController
                didFinishWithIDs:(NSArray *)values
                       teamTitle:(NSString *)title
                          teamId:(NSNumber *)teamId;

@end
