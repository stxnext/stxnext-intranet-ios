//
//  UserDetailsViewController.h
//  Intranet
//
//  Created by Adam on 30.10.2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ClockView.h"
#import "AddOOOFormTableViewController.h"

@protocol UserDetailsTableViewControllerDelegate;
@interface UserDetailsTableViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIWebViewDelegate, NSURLConnectionDelegate, UIActionSheetDelegate, AddOOOFormTableViewControllerDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneDeskLabel;
@property (weak, nonatomic) IBOutlet UILabel *skypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ircLabel;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *addToContactLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *rolesLabel;
@property (weak, nonatomic) IBOutlet UILabel *groupsLabel;
@property (weak, nonatomic) IBOutlet UILabel *explanationLabel;


@property (weak, nonatomic) IBOutlet UITableViewCell *phoneDeskCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *skypeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ircCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *mainCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *addToContactsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *groupsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *rolesCell;

@property (weak, nonatomic) IBOutlet ClockView *clockView;
@property (strong, nonatomic) UIActionSheet *requestActionSheet;

@property (strong, nonatomic) RMUser *user;
@property (nonatomic, assign) BOOL isComeFromAbsences;
@property (nonatomic, assign) BOOL isListStateTommorow;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (nonatomic, weak) id<UserDetailsTableViewControllerDelegate> delegate;

@end


@protocol UserDetailsTableViewControllerDelegate <NSObject>

@optional

- (void)didChangeUserDetailsToMe;

@end
