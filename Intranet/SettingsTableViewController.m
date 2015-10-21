//
//  SettingsTableViewController.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 31.08.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "AFHTTPRequestOperation+Redirect.h"
#import "AppDelegate+Navigation.h"
#import "APIRequest.h"
#import "ActionSheetPicker.h"

@interface SettingsTableViewController ()
//super hero cell
@property (weak, nonatomic) IBOutlet UILabel *superHeroLabel;
@property (weak, nonatomic) IBOutlet UISwitch *superHeroSwitch;

//notifications cell
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;

//logout cell
@property (weak, nonatomic) IBOutlet UIButton *logoutLabel;

//credits cell
@property (weak, nonatomic) IBOutlet UILabel *creditsHeader;
@property (weak, nonatomic) IBOutlet UILabel *developmentHeader;
@property (weak, nonatomic) IBOutlet UILabel *developmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *designHeader;
@property (weak, nonatomic) IBOutlet UILabel *designLabel;

//version cell
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self.navigationItem setTitle:NSLocalizedString(@"Settings", nil)];
    [self.notificationLabel setText:NSLocalizedString(@"Remind me to note my time", nil)];
    
    NSDate *timeReminder = [[NSUserDefaults standardUserDefaults] objectForKey:kTIMEREMINDER];
    if(timeReminder) {
        [self.notificationSwitch setOn:YES];
        [self setNotificationLabelFromTime:timeReminder];
    }

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if(INTERFACE_IS_PAD) {
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout", nil) style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
        [logoutButton setTintColor:[UIColor whiteColor]];
        [self.navigationItem setRightBarButtonItem:logoutButton];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    BOOL superHeroMode = [[NSUserDefaults standardUserDefaults] boolForKey:kHEROMODE];
    [self.superHeroSwitch setOn:superHeroMode];
}

- (void)prepareUI
{
    [self.tableView setRowHeight:UITableViewAutomaticDimension];
    [self.tableView setEstimatedRowHeight:44.0];
    
    [self.view setBackgroundColor:[Branding stxLightGray]];
    [self.superHeroLabel setText:NSLocalizedString(@"I am a SuperHero!", nil)];
    if(iOS8_PLUS) {
        [self.superHeroSwitch setTransform:CGAffineTransformMakeScale(0.75, 0.75)];
        [self.notificationSwitch setTransform:CGAffineTransformMakeScale(0.75, 0.75)];
    }
    
    [self.versionLabel setText:[NSString stringWithFormat:@"STX Intranet %@\nSTX Next Mobile Team 2015",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    [self.logoutLabel setTitle:[NSLocalizedString(@"Logout", nil) uppercaseString] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark actions

- (IBAction)toggleHeroMode:(id)sender {
    [[NSUserDefaults standardUserDefaults] setBool:self.superHeroSwitch.isOn forKey:kHEROMODE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)toggleNotifications:(id)sender {
    if(!self.notificationSwitch.isOn) {
        [self setEmptyNotificationTime];
        return;
    }
    [ActionSheetDatePicker showPickerWithTitle:NSLocalizedString(@"Notification time", nil) datePickerMode:UIDatePickerModeTime selectedDate:[self getDefaultNotificationTime] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        [self setNotificationFromTime:selectedDate];
        [self setNotificationLabelFromTime:selectedDate];
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        [self setEmptyNotificationTime];
    } origin:(UIView *)sender];
}

- (void)setEmptyNotificationTime {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kTIMEREMINDER];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.notificationLabel setText:NSLocalizedString(@"Remind me to note my time", nil)];
    [self.notificationSwitch setOn:NO];
}

- (void)setNotificationFromTime:(NSDate *)date {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = date;
    localNotification.alertBody = NSLocalizedString(@"Remember to note your working hours in the Intranet!", nil);
    localNotification.timeZone = [NSTimeZone localTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    localNotification.repeatInterval = NSCalendarUnitDay;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:kTIMEREMINDER];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setNotificationLabelFromTime:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
    
    NSString *notificationLabelText = [NSString stringWithFormat:@"%@ (%.2ld:%.2ld)", NSLocalizedString(@"Remind me to note my time", nil), (long)hour, (long)minute];
    [self.notificationLabel setText:notificationLabelText];
}

- (NSDate *)getDefaultNotificationTime {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMinute:0];
    [components setHour:17];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:[NSCalendar currentCalendar].calendarIdentifier];
    return [calendar dateFromComponents:components];
}

- (IBAction)logout:(id)sender {
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
                                                  
                                                  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kHEROMODE];
                                                  [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUSERHOURS];
                                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                                  
                                                  // delete all cookies (to remove Google login cookies)
                                                  
                                                  NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                                                  
                                                  for (NSHTTPCookie *cookie in storage.cookies)
                                                  {
                                                      [storage deleteCookie:cookie];
                                                  }
                                                  
                                                  [[NSURLCache sharedURLCache] removeAllCachedResponses];
                                                  
                                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                                  
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:DID_LOGOUT object:nil userInfo:nil];
                                                  
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

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
