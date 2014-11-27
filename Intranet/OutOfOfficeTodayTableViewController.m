//
//  OutOfOfficeTodayTableViewController.m
//  Intranet
//
//  Created by Adam on 19.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "OutOfOfficeTodayTableViewController.h"
#import "AddOOOFormTableViewController.h"
#import "UserDetailsTableViewController.h"
#import "UserListCell.h"

typedef NS_ENUM(NSUInteger, ListState) {
    ListStateOutToday,
    ListStateOutTomorrow,
};

@interface OutOfOfficeTodayTableViewController ()
{
    NSIndexPath *currentIndexPath;
    BOOL canShowNoResultsMessage;
    NSString *searchedString;
    ListState currentListState;
}

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation OutOfOfficeTodayTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartRefreshPeople) name:DID_START_REFRESH_PEOPLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndRefreshPeople) name:DID_END_REFRESH_PEOPLE object:nil];

    currentListState = ListStateOutToday;
    [self showOutViewButton];
    
    [self.tableView hideEmptySeparators];
    [self.searchDisplayController.searchResultsTableView hideEmptySeparators];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self loadUsersFromDatabase];
    NSLog(@"View did appear");
}

- (void)loadUsersFromDatabase
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IS_REFRESH_PEOPLE])
    {
        if (_userList.count == 0)
        {
            [self addActivityIndicator];
        }
        
        return;
    }
    
    NSLog(@"Loading from: Database");

    switch (currentListState)
    {
        case ListStateOutToday:
            _userList = [RMUser loadTodayOutOffOfficePeople];
            break;
            
        case ListStateOutTomorrow:
            _userList = [RMUser loadTomorrowOutOffOfficePeople];
            break;
    }
    
    if (searchedString.length > 0)
    {
        [_userList replaceObjectAtIndex:0 withObject:[NSMutableArray arrayWithArray:[_userList[0] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]]];
        [_userList replaceObjectAtIndex:1 withObject:[NSMutableArray arrayWithArray:[_userList[1] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]]];
        [_userList replaceObjectAtIndex:2 withObject:[NSMutableArray arrayWithArray:[_userList[2] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]]];

            [self.searchDisplayController.searchResultsTableView reloadData];
    }
    else
    {
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_userList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = [_userList[section] count];
    NSInteger count = [_userList[0] count] + [_userList[1] count] + [_userList[2] count];
    
    if (count == 0 && section == 0 && canShowNoResultsMessage)//show once
    {
        [UIAlertView showWithTitle:@"Info"
                           message:@"Nothing to show."
                             style:UIAlertViewStyleDefault
                 cancelButtonTitle:nil
                 otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                 }];
    }
    
    if (number)
    {
        canShowNoResultsMessage = NO;
    }
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMUser *user = _userList[indexPath.section][indexPath.row];
    
    static NSString *CellIdentifier = @"UserCell";
    
    UserListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.userName.text = user.name;
    cell.userImage.layer.cornerRadius = 5;
    cell.userImage.clipsToBounds = YES;
    
    cell.userImage.layer.borderColor = [[UIColor grayColor] CGColor];
    cell.userImage.layer.borderWidth = 1;
    
    cell.clockView.hidden = NO;
    
    NSDateFormatter *absenceDateFormater = [[NSDateFormatter alloc] init];
    absenceDateFormater.dateFormat = @"YYYY-MM-dd";
    
    NSDateFormatter *latesDateFormater = [[NSDateFormatter alloc] init];
    latesDateFormater.dateFormat = @"HH:mm";
    
    __block NSMutableString *hours = [[NSMutableString alloc] initWithString:@""];
    
    if (indexPath.section == 1 || indexPath.section == 2)
    {
        cell.clockView.color = MAIN_YELLOW_COLOR;
        
        [user.lates enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
            RMLate *late = (RMLate *)obj;
            
            NSString *start = [latesDateFormater stringFromDate:late.start];
            NSString *stop = [latesDateFormater stringFromDate:late.stop];
            
            if (start.length || stop.length)
            {
                [hours appendFormat:@" %@ - %@\n", start.length ? start : @"...",
                 stop.length ? stop : @"..."];
            }
        }];
    }
    else if (indexPath.section == 0)
    {
        cell.clockView.color = MAIN_RED_COLOR;
        
        [user.absences enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
            RMAbsence *absence = (RMAbsence *)obj;
            
            NSString *start = [absenceDateFormater stringFromDate:absence.start];
            NSString *stop = [absenceDateFormater stringFromDate:absence.stop];
            
            if (start.length || stop.length)
            {
                [hours appendFormat:@" %@  -  %@\n", start.length ? start : @"...",
                 stop.length ? stop : @"..."];
            }
        }];
    }
    
    [hours setString:[hours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    cell.warningDateLabel.text = hours;
    
    if (user.avatarURL)
    {
        [cell.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:user.avatarURL] forceRefresh:NO];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.rowHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"ABSENCE / HOLIDAY";

        case 1:
            return @"WORK FROM HOME";
            
        case 2:
            return @"OUT OF OFFICE";
    }
    
    return @"";
}


#pragma mark - Search management

- (void)reloadSearchWithText:(NSString *)text
{
    canShowNoResultsMessage = NO;
    searchedString = text;
    
    [self loadUsersFromDatabase];
}

#pragma mark - Search bar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self reloadSearchWithText:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self reloadSearchWithText:@""];
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[UserDetailsTableViewController class]])
    {
        UserListCell *cell = (UserListCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        if (indexPath == nil)
        {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
        }
        
        currentIndexPath = indexPath;
        
        if (indexPath.section == 0)
        {
            ((UserDetailsTableViewController *)segue.destinationViewController).isComeFromAbsences = YES;
        }
        
        ((UserDetailsTableViewController *)segue.destinationViewController).user = _userList[indexPath.section][indexPath.row];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"AddOOOFormTableViewControllerId"] && ![[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        [UIAlertView showWithTitle:@"Error"
                           message:@"No Internet connection."
                             style:UIAlertViewStyleDefault
                 cancelButtonTitle:nil
                 otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                 }];

        return NO;
    }
    
    return YES;
}

- (IBAction)showNewRequest:(id)sender
{
    if (![[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Internet connection." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"New request" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Absence / Holiday", @"Out of office", nil];
        
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 2)
    {
        /*
        UIViewController *_vc = [[UIViewController alloc] init];
        UINavigationController *_nvc = [[UINavigationController alloc] initWithRootViewController:_vc];
        
        [self presentViewController:_nvc animated:YES completion:nil];
        
        return;
        */
        
        UINavigationController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddOOOFormTableViewControllerId"];
        
        [self presentViewController:nvc animated:YES completion:nil];
        
        AddOOOFormTableViewController *form = [nvc.viewControllers firstObject];
        form.currentRequest = buttonIndex;
    }
}

#pragma mark - Notyfications

- (void)didStartRefreshPeople
{
    NSLog(@"START LOAD NOTIFICATION");
    
    if (_userList.count == 0)
    {
        [self addActivityIndicator];
    }
}

- (void)didEndRefreshPeople
{
    NSLog(@"END LOAD NOTIFICATION");
    [self loadUsersFromDatabase];
    [self removeActivityIndicator];
}

- (void)addActivityIndicator
{
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator startAnimating];
    
    self.activityIndicator.center = self.tableView.center;
    [self.tableView addSubview:self.activityIndicator];
    self.tableView.userInteractionEnabled = NO;
}

- (void)removeActivityIndicator
{
    self.tableView.userInteractionEnabled = YES;
    [self.activityIndicator removeFromSuperview];
}

- (IBAction)changeView:(id)sender
{
    currentListState = [self nextListState];
    [self showOutViewButton];
    
    [self loadUsersFromDatabase];
}

- (void)showOutViewButton
{
    [self performBlockOnMainThread:^{
        switch (currentListState)
        {
            case ListStateOutToday:
                [self.viewSwitchButton setTitle:@"Tomorrow"];
                self.title = @"Today";
                self.refreshControl = nil;
                
                break;
                
            case ListStateOutTomorrow:
                [self.viewSwitchButton setTitle:@"Today"];
                self.title = @"Tomorrow";
                
                break;
        }
        
        self.viewSwitchButton.enabled = YES;
        [self.navigationItem setLeftBarButtonItem:self.viewSwitchButton animated:YES];
    } afterDelay:0];
}

- (void)hideOutViewButton
{
    [self performBlockOnMainThread:^{
        self.viewSwitchButton.enabled = NO;
        [self.navigationItem setLeftBarButtonItem:self.viewSwitchButton animated:YES];
    } afterDelay:0];
}

- (ListState)nextListState
{
    switch (currentListState)
    {
            
        case ListStateOutToday:
            return ListStateOutTomorrow;
            
        case ListStateOutTomorrow:
            return ListStateOutToday;
    }
    
    return ListStateOutToday;
}

@end

