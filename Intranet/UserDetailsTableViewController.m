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
#import "NSString+MyRegex.h"
#import "UIImageView+Additions.h"

@interface UserDetailsTableViewController ()
{
    BOOL isPageLoaded;
}

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) UILabel *loadingLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation UserDetailsTableViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView hideEmptySeparators];

    [self resetLabels];
    [self updateGUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartRefreshPeople) name:DID_START_REFRESH_PEOPLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndRefreshPeople) name:DID_END_REFRESH_PEOPLE object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![RMUser myUserId])
    {
        [RMUser loadMeUserId:^{
            [self updateGUI];
        }];
    }
    
    if (![self.user isFault])
    {
        [self updateGUI];
    }
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
    
    CGFloat r = cell.isHidden ? 0 : 56;
    
    return r;
}

#pragma mark - GUI

- (void)updateGUI
{
    if (INTERFACE_IS_PAD)
    {
        if ([RMUser userLoggedType] != UserLoginTypeTrue)
        {
            self.title = @"Info";
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(logout:)];
        }
        else if ([self isLoadedMe]) // my details
        {
            self.title = @"Me";
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(logout:)];
        }
        else // other people
        {
            self.title = @"Info";
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Me"
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(loadMe)];
        }
    }
    else
    {
        if ([self isMeTab]) // me
        {
            if ([RMUser userLoggedType] != UserLoginTypeTrue)
            {
                self.title = @"About";
                
                NSLog(@"%@", self.tabBarController.tabBar);
                
                if (self.webView == nil)
                {
                    isPageLoaded = NO;
                    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.height - self.tabBarController.tabBar.frame.size.height)];
                    self.webView.scalesPageToFit = YES;
                    self.webView.delegate = self;
                }
                
                if (!isPageLoaded)
                {
                    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.stxnext.pl/?set_language=en"]]];
                    
                    [self.view addSubview:self.webView];
                    [self addActivityIndicator];
                }
            }
            else
            {
                self.title = @"Me";
                [self.webView removeFromSuperview];
                self.user = [RMUser me];
            }
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout"
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(logout:)];

        }
        else
        {
            self.title = @"Info";
//            if ([[NSUserDefaults standardUserDefaults] boolForKey:IS_REFRESH_PEOPLE])
//            {
////                if (!self.user)
////                {
////                    [self addActivityIndicator];
////                }
//                
//                return;
//            }
    
        }
    }
    
    [self updateCells];
    
    [self.tableView reloadDataAnimated:NO];
}

- (void)updateCells
{
    if (self.user.avatarURL)
    {
        [self.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:self.user.avatarURL] forceRefresh:NO];
    }
    
    [self.userImage makeRadius:5 borderWidth:1 color:[UIColor grayColor]];
    
    if (self.user.name)
    {
        self.userName.text = self.user.name;
        self.mainCell.hidden = NO;
    }
    else
    {
        self.mainCell.hidden = YES;
    }
    
    if (self.user.phone)
    {
        self.phoneLabel.text = self.user.phone;
        self.phoneCell.hidden = NO;
    }
    else
    {
        self.phoneCell.hidden = YES;
    }
    
    if (self.user.phoneDesk)
    {
        self.phoneDeskLabel.text = self.user.phoneDesk;
        self.phoneDeskCell.hidden = NO;
    }
    else
    {
        self.phoneDeskCell.hidden = YES;
    }
    
    if (self.user.email)
    {
        self.emailLabel.text = self.user.email;
        self.emailCell.hidden = NO;
    }
    else
    {
        self.emailCell.hidden = YES;
    }
    
    if (self.user.skype)
    {
        self.skypeLabel.text = self.user.skype;
        self.skypeCell.hidden = NO;
    }
    else
    {
        self.skypeCell.hidden = YES;
    }
    
    if (self.user.irc)
    {
        self.ircLabel.text = self.user.irc;
        self.ircCell.hidden = NO;
    }
    else
    {
        self.ircCell.hidden = YES;
    }
    
    if (self.user.location)
    {
        self.locationLabel.text = self.user.location;
        self.locationCell.hidden = NO;
    }
    else
    {
        self.locationCell.hidden = YES;
    }
    
    NSString *(^formatValues)(id) = ^(id array){
        NSMutableString *string = [[NSMutableString alloc] initWithString:@""];
        
        for (NSString *value in array)
        {
            [string appendFormat:@"%@, ", value];
        }
        
        [string  replaceCharactersInRange:NSMakeRange(string.length - 2, 2) withString:@""];
        
        return string;
    };
    
    if ([self.user.groups count])
    {
        self.groupsLabel.text = formatValues(self.user.groups);
        self.groupsCell.hidden = NO;
    }
    else
    {
        self.groupsCell.hidden = YES;
    }
    
    if ([self.user.roles count])
    {
        self.rolesLabel.text = formatValues(self.user.roles);
        self.rolesCell.hidden = NO;
    }
    else
    {
        self.rolesCell.hidden = YES;
    }
    
    self.clockView.hidden = ((self.user.lates.count + self.user.absences.count) == 0);
    
    __block NSMutableString *hours = [[NSMutableString alloc] initWithString:@""];
    
    NSDateFormatter *absenceDateFormater = [[NSDateFormatter alloc] init];
    absenceDateFormater.dateFormat = @"YYYY-MM-dd";
    
    NSDateFormatter *latesDateFormater = [[NSDateFormatter alloc] init];
    latesDateFormater.dateFormat = @"HH:mm";
    
    //    if ((self.isComeFromAbsences && self.user.absences.count) || (!self.isComeFromAbsences && !self.user.lates.count && self.user.absences.count))
    if ((self.isComeFromAbsences || !self.user.lates.count) && self.user.absences.count) // prostsza wersja tego co u góry (A && B) || ( !A &&  !C && B)  >>>
    {
        self.clockView.color = MAIN_RED_COLOR;
        
        [self.user.absences enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
            RMAbsence *absence = (RMAbsence *)obj;
            
            if (self.isListStateTommorow == [absence.isTomorrow boolValue])
            {
                NSString *start = [absenceDateFormater stringFromDate:absence.start];
                NSString *stop = [absenceDateFormater stringFromDate:absence.stop];
                
                if (start.length || stop.length)
                {
                    [hours appendFormat:@"%@  -  %@,", start.length ? start : @"...",
                     stop.length ? stop : @"..."];
                }
                
                if (absence.remarks)
                {
                    [hours appendFormat:@" %@\n", absence.remarks];
                }
            }
        }];
    }
    else  if (self.user.lates.count)
    {
        self.clockView.color = MAIN_YELLOW_COLOR;
        
        [self.user.lates enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
            RMLate *late = (RMLate *)obj;
            
            if (self.isListStateTommorow == [late.isTomorrow boolValue])
            {
                NSString *start = [latesDateFormater stringFromDate:late.start];
                NSString *stop = [latesDateFormater stringFromDate:late.stop];
                
                if (start.length || stop.length)
                {
                    [hours appendFormat:@"%@ - %@,", start.length ? start : @"...",
                     stop.length ? stop : @"..."];
                }
                
                if (late.explanation)
                {
                    [hours appendFormat:@" %@\n", late.explanation];
                }
            }
        }];
    }
    
    [hours setString:[hours  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    if (hours.length > 1)
    {
        [hours deleteCharactersInRange:NSMakeRange(hours.length - 1, 1)];
    }
    
    self.explanationLabel.text = hours;
    
    if ([RMUser userLoggedType] != UserLoginTypeTrue)
    {
        self.addToContactsCell.hidden = YES;
    }
    
    if ([self isLoadedMe])
    {
        self.addToContactsCell.hidden = YES;
    }
    
    [self.userName sizeToFit];
    [self.userName layoutIfNeeded];
    [self.explanationLabel sizeToFit];
    
    [self updateAddToContactsButton];
}

- (void)resetLabels
{
    self.phoneLabel.text = @"";
    self.emailLabel.text = @"";
    self.phoneDeskLabel.text = @"";
    self.skypeLabel.text = @"";
    self.ircLabel.text = @"";
    self.userName.text = @"";
    self.addToContactLabel.text = @"";
    self.locationLabel.text = @"";
    self.rolesLabel.text = @"";
    self.groupsLabel.text = @"";
    self.explanationLabel.text = @"";
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
        [UIAlertView alertWithTitle:@"Error" withText:alertText];
    }
}

- (void)phoneCall
{
    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"1234567890+"];
    s = [s invertedSet];
    
    NSString *number = self.user.phone;
    number = [[number componentsSeparatedByCharactersInSet:s] componentsJoinedByString:@""];
    
    [self openUrl:[NSURL URLWithString:[@"tel://" stringByAppendingString:number]] orAlertWithText:@"Call app not found."];
}

- (void)phoneDeskCall
{
    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"1234567890+"];
    s = [s invertedSet];
    
    NSString *number = self.user.phoneDesk;
    number = [[number componentsSeparatedByCharactersInSet:s] componentsJoinedByString:@""];
    
    [self openUrl:[NSURL URLWithString:[@"tel://" stringByAppendingString:number]] orAlertWithText:@"Call app not found."];
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
        [UIAlertView alertWithTitle:@"Error"
                           withText:@"Email app not found."];
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
    if ([RMUser userLoggedType] == UserLoginTypeFalse)
    {
        [[HTTPClient sharedClient] deleteCookies];
        
        // delete all cookies (to remove Google login cookies)
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        for (NSHTTPCookie *cookie in storage.cookies)
        {
            [storage deleteCookie:cookie];
        }
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.user = nil;
        
        [RMUser setUserLoggedType:UserLoginTypeNO];
        
        if (INTERFACE_IS_PHONE)
        {
            [APP_DELEGATE goToTabAtIndex:TabIndexUserList];
        }
        else
        {
            [APP_DELEGATE showLoginScreenForiPad];
        }
    }
    else
    {
        [[HTTPClient sharedClient] startOperation:[APIRequest logout]
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              // logout error
                                              
                                              // We expect 302
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              if ([operation redirectToLoginView])
                                              {
                                                  [[HTTPClient sharedClient] deleteCookies];
                                                  
                                                  // delete all cookies (to remove Google login cookies)
                                                  
                                                  NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                                                  
                                                  for (NSHTTPCookie *cookie in storage.cookies)
                                                  {
                                                      [storage deleteCookie:cookie];
                                                  }
                                                  
                                                  [[NSURLCache sharedURLCache] removeAllCachedResponses];
                                                  
                                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                                  
                                                  self.user = nil;
                                                  self.webView = nil;
                                                  isPageLoaded = NO;
                                                  
                                                  [RMUser setMyUserId:nil];
                                                  
                                                  [RMUser setUserLoggedType:UserLoginTypeNO];
                                                  
                                                  if (INTERFACE_IS_PHONE)
                                                  {
                                                      [APP_DELEGATE goToTabAtIndex:TabIndexUserList];
                                                  }
                                                  else
                                                  {
                                                      [APP_DELEGATE showLoginScreenForiPad];
                                                  }
                                              }
                                              else
                                              {
                                                  // logout error
                                              }
                                          }];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    isPageLoaded = YES;
    [self removeActivityIndicator];
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
            NSLog(@"Mail cancelled");
        }
            break;
            
        case MFMailComposeResultSaved:
        {
            NSLog(@"Mail saved");
        }
            break;
            
        case MFMailComposeResultSent:
        {
            NSLog(@"Mail sent");
        }
            break;
            
        case MFMailComposeResultFailed:
        {
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
        }
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Rotations

- (BOOL)shouldAutorotate
{
    [self updateGUI];
    
    return YES;
}

#pragma mark - Notyfications

- (void)didStartRefreshPeople
{
    NSLog(@"START LOAD NOTIFICATION");
    
    if (!self.user)
    {
        [self addActivityIndicator];
    }
}

- (void)didEndRefreshPeople
{
    NSLog(@"END LOAD NOTIFICATION");
    
//    [self loadUser];
    if (![self.user isFault])
    {
        [self updateGUI];
    }

    [self removeActivityIndicator];
}

- (void)addActivityIndicator
{
    [self.activityIndicator removeFromSuperview];
    self.tableView.userInteractionEnabled = NO;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator startAnimating];
    
    self.activityIndicator.center = self.tableView.center;
    [self.tableView addSubview:self.activityIndicator];
}

- (void)removeActivityIndicator
{
    self.tableView.userInteractionEnabled = YES;
    [self.activityIndicator removeFromSuperview];
}

#pragma mark - Other

- (BOOL)isLoadedMe
{
    return [self.user.id integerValue] == [[RMUser myUserId] integerValue];
}

- (BOOL)isMeTab
{
    return [[self.navigationController viewControllers] count] == 1;
}

- (void)loadMe
{
    self.user = [RMUser me];

    if (self.user && ![self.user isFault])
    {
        if ([self.delegate respondsToSelector:@selector(didChangeUserDetailsToMe)])
        {
            [self.delegate didChangeUserDetailsToMe];
        }
    }
    
    [self updateGUI];
}

@end
