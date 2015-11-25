//
//  UserDetailsViewController.m
//  Intranet
//
//  Created by Adam on 30.10.2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UserDetailsTableViewController.h"
#import "AddHoursTableViewController.h"
#import "RMUser+AddressBook.h"
#import "AFHTTPRequestOperation+Redirect.h"
#import "APIRequest.h"
#import "AppDelegate+Navigation.h"
#import "NSString+MyRegex.h"
#import "UIImageView+Additions.h"
#import "UserDetailsTableViewCell.h"
#import "UIImage+Color.h"
#import "CellularRangeDetector.h"
#import "UserWorkedHours.h"
#import "MBProgressHUD.h"
#import "CalendarViewController.h"
#import "NSDate+TimePeriods.h"

#define kUSER_LOCATION @"Office"
#define kUSER_EMAIL @"E-mail"
#define kUSER_PHONE @"Tel"
#define kUSER_SKYPE @"Skype"
#define kUSER_IRC @"IRC"

@interface UserDetailsTableViewController ()
{
    BOOL isPageLoaded;
    NSDictionary *userDetails;
    NSArray *detailsOrder;
    UIRefreshControl *refresh;
}

@property (weak, nonatomic) IBOutlet UIImageView *profileBackground;
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
    
    if (INTERFACE_IS_PHONE) {
        [self.view setBackgroundColor:[Branding stxLightGray]];
    } else {
        [self.view setBackgroundColor:[UIColor whiteColor]];
    }
    
    if ([self isMeTab] && !self.user.name) self.user = [RMUser me];
    if(self.user.avatarURL) [self.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:self.user.avatarURL] forceRefresh:NO];
    [self.userImage makeRadius:(self.userImage.frame.size.height / 2) borderWidth:2.0 color:[Branding stxGreen]];
    [[UITableViewHeaderFooterView appearance] setTintColor:[UIColor clearColor]];

    [self updateGUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartRefreshPeople) name:DID_START_REFRESH_PEOPLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndRefreshPeople) name:DID_END_REFRESH_PEOPLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearData) name:DID_LOGOUT object:nil];
    
    if (INTERFACE_IS_PAD) {
        UIImage *img = self.profileBackground.image;
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
        self.profileBackground.image = img;
    }
    
    if ([self isMeTab]) {
        [self requestUserHours];
        [self.refreshControl addTarget:self action:@selector(requestUserHours) forControlEvents:UIControlEventValueChanged];
        self.refreshControl.backgroundColor = [Branding stxLightGray];
        self.refreshControl.tintColor = [UIColor darkGrayColor];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Refresh", nil) attributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL superHeroMode = [[NSUserDefaults standardUserDefaults] boolForKey:kHEROMODE];
    if(superHeroMode)
    {
        [self isFemale] ? [self.profileBackground setImage:[UIImage imageNamed:@"superhero_her"]] : [self.profileBackground setImage:[UIImage imageNamed:@"superhero_him"]];
    }
    else [self.profileBackground setImage:[UIImage imageNamed:@"superhero_none"]];
    if ([self isMeTab] && !self.user.name) self.user = [RMUser me];
    
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
    
    [self updateAddToContactsButton];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(![self isMeTab])
    {
        userDetails = nil;
        detailsOrder = nil;
    }
}

- (void)requestUserHours
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSNumber *personalIdentifier = [[NSUserDefaults standardUserDefaults] valueForKey:@"myUserId"];
    [[HTTPClient sharedClient] startOperation:[APIRequest getWorkedHoursForUser:personalIdentifier] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:kUSERHOURS];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[UserWorkedHours sharedHours] setHoursFromDictionary:responseObject];
        [self.tableView reloadData];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.refreshControl endRefreshing];
    }];
}

//check what kind of user data is available (not nil) and prepare a dictionary containing only these data which should be displayed on user page... additionally create an array of dictionary keys to maintain proper order of tableview cells (it is necessary since [userDetails allKeys] also returns keys in an array, but not in order)
- (void)prepareUserDetails
{
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    NSMutableArray *availableInfo = [[NSMutableArray alloc] init];
    
    if(self.user.location)
    {
        [userData setObject:self.user.location forKey:kUSER_LOCATION];
        [availableInfo addObject:kUSER_LOCATION];
    }
    if(self.user.email)
    {
        [userData setObject:self.user.email forKey:kUSER_EMAIL];
        [availableInfo addObject:kUSER_EMAIL];
    }
    if(self.user.phone)
    {
        //it would be nice to have all telephone numbers in the same format
        NSString *phoneString = [[[NSString stringWithFormat:@"%@", self.user.phone] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if([phoneString hasPrefix:@"+48"] && [phoneString length] > 3) phoneString = [phoneString substringFromIndex:3];
        
        [userData setObject:phoneString forKey:kUSER_PHONE];
        [availableInfo addObject:kUSER_PHONE];
    }
    if(self.user.skype)
    {
        [userData setObject:self.user.skype forKey:kUSER_SKYPE];
        [availableInfo addObject:kUSER_SKYPE];
    }
    if(self.user.irc)
    {
        [userData setObject:self.user.irc forKey:kUSER_IRC];
        [availableInfo addObject:kUSER_IRC];
    }
    
    userDetails = [userData copy];
    detailsOrder = [availableInfo copy];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetailsTableViewCell *cell = (UserDetailsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if(indexPath.section == 0 && [self isMeTab] && indexPath.row != 1) {
        if(indexPath.row == 0) {
            [self requestUserHours];
            return;
        }
        NSDate *requestedHoursStartDate = [NSDate firstDayOfCurrentQuarter];
        NSDate *requestedHoursEndDate = [NSDate lastDayOfCurrentQuarter];
        BOOL quarterMode = YES;
        if(indexPath.row == 2) {
            requestedHoursStartDate = [NSDate firstDayOfCurrentMonth];
            requestedHoursEndDate = [NSDate lastDayOfCurrentMonth];
            quarterMode = NO;
        }
        [[HTTPClient sharedClient] startOperation:[APIRequest getUserTimesFromDate:requestedHoursStartDate toDate:requestedHoursEndDate] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            CalendarViewController *calController = [[CalendarViewController alloc] init];
            calController.quarterMode = quarterMode;
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:calController];
            [self presentViewController:navController animated:YES completion:nil];
        } failure:nil];
    }
    
    if ([cell.header.text isEqualToString:kUSER_PHONE])
    {
        [self phoneCall];
    }
    else if ([cell.header.text isEqualToString:kUSER_EMAIL])
    {
        [self emailSend];
    }
    else if ([cell.header.text isEqualToString:kUSER_SKYPE])
    {
        [self skypeCall];
    }
    else if ([cell.header.text isEqualToString:kUSER_IRC])
    {
        [self ircSend];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isHeaderIndex:indexPath]) return 44.0f;
    return 32;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"userDetailsCell";
    if([self isHeaderIndex:indexPath]) cellIdentifier = @"userInfoCell";
    UserWorkedHours *workedHours = [UserWorkedHours sharedHours];

    UserDetailsTableViewCell *myCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!myCell) myCell = [[UserDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    if([self isHeaderIndex:indexPath])
    {
        if([self isInHoursSection:indexPath])
        {
            [myCell.header setText:NSLocalizedString(@"Worked hours", nil)];
            if(workedHours.getTodaysArrival) [myCell.details setText:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Today from", nil), workedHours.getTodaysArrival]];
            [myCell setSelectionStyle:UITableViewCellSelectionStyleDefault];
            return myCell;
        }
        [myCell.header setText:self.user.name];
        [myCell.details setText:[[self.user.roles componentsJoinedByString:@", "] uppercaseString]];
    }
    else
    {
        if([self isInHoursSection:indexPath])
        {
            NSNumber *diff = [NSNumber numberWithFloat:0.1];
            switch (indexPath.row) {
                case 1:
                    [myCell.header setText:NSLocalizedString(@"Today", nil)];
                    [myCell.details setText:[NSString stringWithFormat:@"%@ (%@)", workedHours.getTodaysSum, workedHours.getTodaysDiff]];
                    diff = workedHours.getTodaysDiff;
                    [myCell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    break;
                case 2:
                    [myCell.header setText:NSLocalizedString(@"Month", nil)];
                    [myCell.details setText:[NSString stringWithFormat:@"%@ (%@)", workedHours.getMonthSum, workedHours.getMonthDiff]];
                    diff = workedHours.getMonthDiff;
                    break;
                case 3:
                    [myCell.header setText:NSLocalizedString(@"Quarter", nil)];
                    [myCell.details setText:[NSString stringWithFormat:@"%@ (%@)", workedHours.getQuarterSum, workedHours.getQuarterDiff]];
                    diff = workedHours.getQuarterDiff;
                    break;
                default:
                    break;
            }
            if(!diff) [myCell.details setText:@""];
            else if([diff floatValue] <= 0) [myCell.details setTextColor:[UIColor redColor]];
            return myCell;
        }
        NSString *currentKey = [detailsOrder objectAtIndex:indexPath.row - 1];
        [myCell.header setText:[NSString stringWithFormat:@"%@",currentKey]];
        [myCell.details setText:[userDetails objectForKey:currentKey]];
        
        //we don't want the office row to be selectable since it doesn't trigger any action
        if([currentKey isEqualToString:kUSER_LOCATION])
        {
            [myCell.header setText:NSLocalizedString(@"Office", nil)];
            [myCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    }

    return myCell;
}

- (BOOL)isInHoursSection:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0 && [self isMeTab]);
}

- (BOOL)isHeaderIndex:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) return YES;
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self isMeTab] && section == 0) return 4;
    [self prepareUserDetails];
    return [[userDetails allKeys] count] + 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([self isMeTab]) return 2;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0) return 12.0f;
    return 20.0f;
}

#pragma mark - GUI

- (void)updateGUI
{
    if (INTERFACE_IS_PAD)
    {
        if ([self isMeTab]) {
            
            self.user = [RMUser me];
        }
        
        if ([RMUser userLoggedType] != UserLoginTypeTrue)
        {
            self.title = NSLocalizedString(@"Info", nil);
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout", nil)
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(logout:)];
        }
        else if ([self isLoadedMe]) // my details
        {
            self.title = NSLocalizedString(@"Me", nil);
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout", nil)
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(logout:)];
        }
        else // other people
        {
            self.title = NSLocalizedString(@"Info", nil);
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Me", nil)
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
                self.title = NSLocalizedString(@"About", nil);
                
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
                self.title = NSLocalizedString(@"Me", nil);
                [self.webView removeFromSuperview];
                self.user = [RMUser me];
            }
        }
        else self.title = NSLocalizedString(@"Info", nil);
    }
    
    [self.tableView reloadDataAnimated:NO];
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
    if(![CellularRangeDetector hasCellularCoverage]) return;
    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"1234567890+"];
    s = [s invertedSet];
    
    NSString *number = [userDetails objectForKey:kUSER_PHONE];
    number = [[number componentsSeparatedByCharactersInSet:s] componentsJoinedByString:@""];
    
    [self openUrl:[NSURL URLWithString:[@"tel://" stringByAppendingString:number]] orAlertWithText:NSLocalizedString(@"Call app not found.", nil)];
}

- (void)phoneDeskCall
{
    if(![CellularRangeDetector hasCellularCoverage]) return;
    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"1234567890+"];
    s = [s invertedSet];
    
    NSString *number = self.user.phoneDesk;
    number = [[number componentsSeparatedByCharactersInSet:s] componentsJoinedByString:@""];
    
    [self openUrl:[NSURL URLWithString:[@"tel://" stringByAppendingString:number]] orAlertWithText:NSLocalizedString(@"Call app not found.",nil)];
}

- (void)emailSend
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSArray *toRecipents = [NSArray arrayWithObject:[userDetails objectForKey:kUSER_EMAIL]];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        [[mc navigationBar] setTintColor:[UIColor whiteColor]];
        mc.mailComposeDelegate = self;
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    }
    else
    {
        [UIAlertView alertWithTitle:NSLocalizedString(@"Error", nil)
                           withText:NSLocalizedString(@"Email app not found.", nil)];
    }
}

- (void)skypeCall
{
    [self openUrl:[NSURL URLWithString:[@"skype://" stringByAppendingString:[userDetails objectForKeyedSubscript:kUSER_SKYPE]]]
  orAlertWithText:NSLocalizedString(@"Skype app not found.", nil)];
}

- (void)ircSend
{
    [self openUrl:[NSURL URLWithString:[@"irc://" stringByAppendingString:[userDetails objectForKeyedSubscript:kUSER_IRC]]]
  orAlertWithText:NSLocalizedString(@"IRC app not found.", nil)];
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
    UIImage *removeImage = [UIImage imageNamed:@"forbidden27"];
    UIImage *addImage = [UIImage imageNamed:@"add54"];
    
    if([self isMeTab])
    {
        [self.actionButton setImage:addImage forState:UIControlStateNormal];
        return;
    }
    
    if ([_user isInContacts]) [self.actionButton setImage:removeImage forState:UIControlStateNormal];
    else [self.actionButton setImage:addImage forState:UIControlStateNormal];
}

- (IBAction)logout:(id)sender //left only for iPad purposes, probably will be changed or removed after new version for iPad is released
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
                                                  
                                                  [self clearData];
                                                  
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

- (void)clearData
{
    self.user = nil;
    self.webView = nil;
    isPageLoaded = NO;
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
    self.loadingLabel.text = NSLocalizedString(@"Loading error.", nil);
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
    if (INTERFACE_IS_PAD) {
        return [self splitViewController] ? NO : YES;
    }
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

- (BOOL)isFemale {
    NSArray *nameSplit = [self.user.name componentsSeparatedByString:@" "];
    if(nameSplit && nameSplit.count > 1)
    {
        NSString *firstName = [nameSplit firstObject];
        if([firstName hasSuffix:@"a"]) return YES;
    }
    return NO;
}

#pragma mark absence/contact button actions

- (IBAction)triggerAction:(id)sender {
    if([self isMeTab]) [self showNewRequest:sender];
    else [self addToContacts];
}

- (void)showNewRequest:(id)sender
{
    if (![[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Internet connection." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    } else {
        if (INTERFACE_IS_PHONE) {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"New request", nil)
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:NSLocalizedString(@"Add hours",nil),NSLocalizedString(@"I'll be late!",nil), NSLocalizedString(@"Absence/Holiday", nil), NSLocalizedString(@"Out of office", nil) , nil];
            
            [actionSheet showFromTabBar:self.tabBarController.tabBar];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"Requesting projects list", nil);
        
        [[HTTPClient sharedClient] startOperation:[APIRequest getProjectsList] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            
            if (INTERFACE_IS_PHONE)
            {
                UINavigationController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTimeEntryFormViewController"];
                AddHoursTableViewController *hoursVc = (AddHoursTableViewController *)nvc.topViewController;
                hoursVc.projectsList = [responseObject objectForKey:@"projects"];
                if(hoursVc.projectsList) [self presentViewController:nvc animated:YES completion:nil];
                else {
                    UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Request failed", nil) message:NSLocalizedString(@"Couldn't parse projects list", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [failureAlert show];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Request failed", nil) message:NSLocalizedString(@"Couldn't obtain projects list", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [failureAlert show];
        }];
    }
    else if (buttonIndex == 1)
    {
        if (INTERFACE_IS_PHONE)
        {
            UINavigationController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LatenessFormViewControllerId"];
            
            [self presentViewController:nvc animated:YES completion:nil];
        }
    }
    else if (buttonIndex < 4)
    {
        if (INTERFACE_IS_PHONE)
        {
            UINavigationController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddOOOFormTableViewControllerId"];
            
            [self presentViewController:nvc animated:YES completion:nil];
            
            AddOOOFormTableViewController *form = [nvc.viewControllers firstObject];
            form.currentRequest = (int)(buttonIndex - 2);
            form.delegate = self;
        }
    }
}

@end
