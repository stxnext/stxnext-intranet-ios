//
//  UserDetailsViewController.m
//  Intranet
//
//  Created by Adam on 30.10.2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UserDetailsTableViewController.h"
#import "RMUser+AddressBook.h"
#import "AFHTTPRequestOperation+Redirect.h"
#import "APIRequest.h"
#import "AppDelegate+Navigation.h"
#import "CurrentUser.h"

@interface UserDetailsTableViewController ()
{
    BOOL isPageLoaded;
}

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UILabel *loadingLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation UserDetailsTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //code here
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //code here
}

- (void)viewWillAppear:(BOOL)animated
{
    //code here
    
    [self loadUser];
    [self updateAddToContactsButton];
    
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //code here
}

- (void)viewWillDisappear:(BOOL)animated
{
    //code here
    
    [super viewWillDisappear:animated];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.phoneCell)
    {
        [self phoneCall];
    }
    else if (cell == self.phoneDeskCell)
    {
        [self phoneDeskCall];
    }
    else if (cell == self.emailCell)
    {
        [self emailSend];
    }
    else if (cell == self.skypeCell)
    {
        [self skypeCall];
    }
    else if (cell == self.ircCell)
    {
        [self ircSend];
    }
    else if (cell == self.addToContactsCell)
    {
        [self addToContacts];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == self.mainCell)
    {
        float size = self.explanationLabel.frame.size.height + 20 + self.userName.frame.size.height + 20;
        
        return size > cell.frame.size.height ? size : cell.frame.size.height;
    }
    
    return cell.isHidden ? 0 : cell.frame.size.height;
}

#pragma mark - Actions

- (void)openUrl:(NSURL *)url orAlertWithText:(NSString *)alertText
{
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
    else
    {
        [UIAlertView showErrorWithMessage:alertText handler:nil];
    }
}

- (void)phoneCall
{
    [self openUrl:[NSURL URLWithString:[@"tel://" stringByAppendingString:self.user.phone]]
  orAlertWithText:@"Call app not found."];
}

- (void)phoneDeskCall
{
    [self openUrl:[NSURL URLWithString:[@"tel://" stringByAppendingString:self.user.phoneDesk]]
  orAlertWithText:@"Call app not found."];
}

- (void)emailSend
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSArray *toRecipents = [NSArray arrayWithObject:self.user.email];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else
    {
        [UIAlertView showErrorWithMessage:@"Email app not found." handler:nil];
    }
}

- (void)skypeCall
{
    [self openUrl:[NSURL URLWithString:[@"skype://" stringByAppendingString:self.user.skype]]
  orAlertWithText:@"Skype app not found."];
}

- (void)ircSend
{
    [self openUrl:[NSURL URLWithString:[@"irc://" stringByAppendingString:self.user.irc]]
  orAlertWithText:@"IRC app not found."];
}

- (void)addToContacts
{
    if ([_user isInContacts])
    {
        [_user removeFromContacts];
    }
    else
    {
        [_user addToContacts];
    }
    
    [self updateAddToContactsButton];
}

- (void)updateAddToContactsButton
{
    if ([_user isInContacts])
    {
        self.addToContactLabel.text = @"remove from contacts";
    }
    else
    {
        self.addToContactLabel.text = @"add to contacts";
    }
}

- (IBAction)logout:(id)sender
{
    [[CurrentUser singleton] logoutUserWithStart:^(NSDictionary *params) {
        
    } end:^(NSDictionary *params) {
        
    } success:^(NSDictionary *params) {
        
        self.user = nil;
        
        if (!INTERFACE_IS_PAD)
        {
            [APP_DELEGATE goToTabAtIndex:TabIndexUserList];
        }
        else
        {
            [APP_DELEGATE showLoginScreenForiPad];
        }
    } failure:^(NSDictionary *data) {
        
    }];
}

#pragma mark - GUI

- (void)loadUser
{
    if (self.navigationController.viewControllers.count > 1 || INTERFACE_IS_PAD)
    {
        self.title = @"Info";
        
        if (INTERFACE_IS_PAD)
        {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(logout:)];
        }
        
        [self updateGUI];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(logout:)];
        if ([[CurrentUser singleton] userLoginType] == UserLoginTypeTrue)
        {
            if (!self.user)
            {
                [self addEmptyView];
                [self.webView removeFromSuperview];
                
                self.title = @"Me";
                
                [[CurrentUser singleton] userIdWithStart:^(NSDictionary *params) {
                    
                } end:^(NSDictionary *params) {
                    
                } success:^(NSString *userId) {
                    [self loadMe];
                } failure:^(NSDictionary *data) {
                    
                }];
            }
        }
        else
        {
            self.title = @"About";
            
            if (self.webView == nil)
            {
                isPageLoaded = NO;
                self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height - 114)];
                self.webView.scalesPageToFit = YES;
                self.webView.delegate = self;
            }

            if (!isPageLoaded)
            {
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.stxnext.pl/?set_language=en"]]];
                
                [self.view addSubview:self.webView];
                [self addEmptyView];
            }
        }
    }
}

- (void)loadMe
{
    [[CurrentUser singleton] userWithStart:^(NSDictionary *params) {
        
    } end:^(NSDictionary *params) {
        
        [self removeEmptyView];
        self.tableView.scrollEnabled = YES;
        
        [self updateGUI];
        [self.tableView reloadData];
        
    } success:^(RMUser *user) {
        
        self.user = user;
        
    } failure:^(NSDictionary *data) {
        
    }];
}

- (void)updateGUI
{
    [self.tableView hideEmptySeparators];
    
    if (self.user.avatarURL)
    {
        [self.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:self.user.avatarURL]];
    }
    
    self.userImage.layer.cornerRadius = 5;
    self.userImage.clipsToBounds = YES;
    self.userImage.layer.borderColor = [[UIColor grayColor] CGColor];
    self.userImage.layer.borderWidth = 1;
    
    self.userName.text = self.user.name;
    
    if (self.user.phone)
    {
        self.phoneLabel.text = self.user.phone;
    }
    else
    {
        self.phoneCell.hidden = YES;
    }
    
    if (self.user.phoneDesk)
    {
        self.phoneDeskLabel.text = self.user.phoneDesk;
    }
    else
    {
        self.phoneDeskCell.hidden = YES;
    }
    
    if (self.user.email)
    {
        self.emailLabel.text = self.user.email;
    }
    else
    {
        self.emailCell.hidden = YES;
    }
    
    if (self.user.skype)
    {
        self.skypeLabel.text = self.user.skype;
    }
    else
    {
        self.skypeCell.hidden = YES;
    }
    
    if (self.user.irc)
    {
        self.ircLabel.text = self.user.irc;
    }
    else
    {
        self.ircCell.hidden = YES;
    }
    
    if (self.user.location)
    {
        self.locationLabel.text = self.user.location;
    }
    else
    {
        self.locationCell.hidden = YES;
    }
    
    if ([self.user.groups count])
    {
        NSMutableString *string = [[NSMutableString alloc] initWithString:@""];
        
        for (NSString *group in self.user.groups)
        {
            [string appendFormat:@"%@, ", group];
        }
        
        [string  replaceCharactersInRange:NSMakeRange(string.length - 2, 2) withString:@""];
        
        self.groupsLabel.text = string;
    }
    else
    {
        self.groupsCell.hidden = YES;
    }
    
    if ([self.user.roles count])
    {
        NSMutableString *string = [[NSMutableString alloc] initWithString:@""];
        
        for (NSString *role in self.user.roles)
        {
            [string appendFormat:@"%@, ", role];
        }
        
        [string replaceCharactersInRange:NSMakeRange(string.length - 2, 2) withString:@""];
        
        self.rolesLabel.text = string;
    }
    else
    {
        self.rolesCell.hidden = YES;
    }
    
    self.clockView.hidden = ((self.user.lates.count + self.user.absences.count) == 0);
    
    __block NSMutableString *hours = [[NSMutableString alloc] initWithString:@""];
    __block NSMutableString *explanation = [[NSMutableString alloc] initWithString:@""];
    
    NSDateFormatter *absenceDateFormater = [[NSDateFormatter alloc] init];
    absenceDateFormater.dateFormat = @"YYYY-MM-dd";
    
    NSDateFormatter *latesDateFormater = [[NSDateFormatter alloc] init];
    latesDateFormater.dateFormat = @"HH:mm";
    
    if (self.user.lates.count)
    {
        self.clockView.color = MAIN_YELLOW_COLOR;
        
        [self.user.lates enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
            RMLate *late = (RMLate *)obj;
            
            NSString *start = [latesDateFormater stringFromDate:late.start];
            NSString *stop = [latesDateFormater stringFromDate:late.stop];
            
            if (start.length || stop.length)
            {
                [hours appendFormat:@" %@ - %@", start.length ? start : @"...",
                 stop.length ? stop : @"..."];
            }
            
            if (late.explanation)
            {
                [explanation appendFormat:@" %@", late.explanation];
            }
        }];
    }
    else if (self.user.absences.count)
    {
        self.clockView.color = MAIN_RED_COLOR;
        
        [self.user.absences enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
            RMAbsence *absence = (RMAbsence *)obj;
            
            NSString *start = [absenceDateFormater stringFromDate:absence.start];
            NSString *stop = [absenceDateFormater stringFromDate:absence.stop];
            
            if (start.length || stop.length)
            {
                [hours appendFormat:@" %@  -  %@", start.length ? start : @"...",
                 stop.length ? stop : @"..."];
            }
            
            if (absence.remarks)
            {
                [explanation appendFormat:@" %@", absence.remarks];
            }
        }];
    }
    
    [hours setString:[hours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    [explanation setString:[explanation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    NSString *text = [NSString stringWithFormat:@"%@%@%@", hours, (hours.length && explanation.length ? @"\n" : @""), explanation];
    
    self.explanationLabel.text = text;
    
    if (self.navigationController.viewControllers.count <= 1 || [[CurrentUser singleton] userLoginType] != UserLoginTypeTrue)
    {
        self.addToContactsCell.hidden = YES;
    }
    
    [self.userName sizeToFit];
    [self.userName layoutIfNeeded];
    [self.explanationLabel sizeToFit];
    
    [self.tableView reloadData];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    isPageLoaded = YES;
    [self removeEmptyView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    isPageLoaded = NO;
    
    CGPoint center = self.loadingLabel.center;
    self.loadingLabel.text = @"Loading error.";
    [self.loadingLabel sizeToFit];
    
    self.loadingLabel.center = center;
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
        {
            DDLogInfo(@"Mail cancelled");
        }
            break;
            
        case MFMailComposeResultSaved:
        {
            DDLogInfo(@"Mail saved");
        }
            break;
            
        case MFMailComposeResultSent:
        {
            DDLogInfo(@"Mail sent");
        }
            break;
            
        case MFMailComposeResultFailed:
        {
            DDLogInfo(@"Mail sent failure: %@", [error localizedDescription]);
        }
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)shouldAutorotate
{
    [self updateGUI];
    
    return YES;
}

- (void)addEmptyView
{
    CGRect frame = [[UIScreen mainScreen] bounds];

    [self.emptyView removeFromSuperview];
    
    self.emptyView = [[UIView alloc] initWithFrame:frame];
    self.emptyView.backgroundColor = [UIColor whiteColor];
    
    self.loadingLabel = [[UILabel alloc] init];
    self.loadingLabel.text = @"Loading...";
    [self.loadingLabel sizeToFit];
    self.loadingLabel.center = self.emptyView.center;
    [self.emptyView addSubview:self.loadingLabel];

    if (self.activityView == nil)
    {
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityView startAnimating];
    }

    CGPoint center = self.emptyView.center;
    center.y -= self.loadingLabel.frame.size.height/2 + self.activityView.frame.size.height/2;
    self.activityView.center = center;
    [self.emptyView addSubview:self.activityView];
    
    self.tableView.scrollEnabled = NO;
    [self.view addSubview:self.emptyView];
}

- (void)removeEmptyView
{
    [self.emptyView removeFromSuperview];
}

@end
