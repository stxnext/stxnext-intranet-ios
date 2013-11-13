//
//  UserTableViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface UserTableViewController : UITableViewController<LoginViewControllerDelegate>
{
    UIActionSheet* _actionSheet;
    NSArray* _userList;
    UIActionSheet *actionSheet;
}

- (IBAction)showAction:(id)sender;

@end
