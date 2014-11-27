//
//  OutOfOfficeTodayTableViewController.h
//  Intranet
//
//  Created by Adam on 19.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OutOfOfficeTodayTableViewController : UITableViewController <UIActionSheetDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_userList;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *viewSwitchButton;

- (IBAction)changeView:(id)sender;

@end
