//
//  ListTableViewController.m
//  Intranet
//
//  Created by Adam on 28.11.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "ListTableViewController.h"

@interface ListTableViewController ()

@end

@implementation ListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = YES;
 
    [self.tableView hideEmptySeparators];
    [self.searchDisplayController.searchResultsTableView hideEmptySeparators];
    
    currentListState = [self nextListState];
    [self showOutViewButton];
}

- (void)hideOutViewButton
{
    [self performBlockOnMainThread:^{
        self.viewSwitchButton.enabled = NO;
        [self.navigationItem setLeftBarButtonItem:self.viewSwitchButton animated:YES];
    } afterDelay:0];
}

- (IBAction)changeView:(id)sender
{
    currentListState = [self nextListState];
    [self showOutViewButton];
    [self loadUsersFromDatabase];

//    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [self showNoSelectionUserDetails];
}

- (ListState)nextListState
{
    NSAssert(NO, @"Subclasses need to overwrite this method");
    return ListStateNotSet;
}

- (void)showOutViewButton
{
    NSAssert(NO, @"Subclasses need to overwrite this method");
}

#pragma mark - Data

- (void)loadUsersFromDatabase
{
    switch (currentListState)
    {
        case ListStateAll:
        {
            if (self.allUsers.count == 0)
            {
                self.allUsers = [JSONSerializationHelper objectsWithClass:[RMUser class]
                                                       withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                                        ascending:YES
                                                                                                         selector:@selector(localizedCompare:)]
                                                            withPredicate:[NSPredicate predicateWithFormat:@"isActive = YES AND isClient = NO AND isFreelancer = NO"]
                                                         inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
            }
            
            if (searchedString.length > 0)
            {
                userList = [NSMutableArray arrayWithArray:[self.allUsers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
            }
            else
            {
                userList = [NSMutableArray arrayWithArray:self.allUsers];
            }
        }
            break;
        case ListStateOutToday:
        {
            if (self.todayOutOffOfficePeople.count == 0)
            {
                self.todayOutOffOfficePeople = [RMUser loadTodayOutOffOfficePeople];
            }
            
            if (searchedString.length > 0)
            {
                userList = [NSMutableArray arrayWithCapacity:3];
                userList[0] = [NSMutableArray arrayWithArray:[self.todayOutOffOfficePeople[0] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
                userList[1] = [NSMutableArray arrayWithArray:[self.todayOutOffOfficePeople[1] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
                userList[2] = [NSMutableArray arrayWithArray:[self.todayOutOffOfficePeople[2] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
            }
            else
            {
                userList = [NSMutableArray arrayWithArray:self.todayOutOffOfficePeople];
            }
        }
            break;
            
        case ListStateOutTomorrow:
        {
            if (self.tomorrowOutOffOfficePeople.count == 0)
            {
                self.tomorrowOutOffOfficePeople = [RMUser loadTomorrowOutOffOfficePeople];
            }
            
            if (searchedString.length > 0)
            {
                userList = [NSMutableArray arrayWithCapacity:3];
                userList[0] = [NSMutableArray arrayWithArray:[self.tomorrowOutOffOfficePeople filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
                userList[1] = [NSMutableArray arrayWithArray:[self.tomorrowOutOffOfficePeople filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
                userList[2] = [NSMutableArray arrayWithArray:[self.tomorrowOutOffOfficePeople filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains[cd] %@", searchedString]]];
            }
            else
            {
                userList = [NSMutableArray arrayWithArray:self.tomorrowOutOffOfficePeople];
            }
            
        }
            break;
            
        default: break;
    }
    
    if (searchedString.length > 0)
    {
        [self.searchDisplayController.searchResultsTableView reloadDataAnimated:YES];
    }
    else
    {
        [self.tableView reloadDataAnimated:YES];
    }
}

#pragma mark - UITableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserCell";
    
    UserListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    RMUser *user;
    NSInteger realSection = [self realSectionForNotEmptySection:indexPath.section];

    if (currentListState == ListStateAll)
    {
        user = userList[indexPath.row];
    }
    else
    {
        user = userList[realSection][indexPath.row];
    }
    
    cell.userName.text = user.name;
    
    [cell.userImage makeRadius:5 borderWidth:1 color:[UIColor grayColor]];
    
    if (!isDatabaseBusy)
    {
        __block BOOL shouldHiddeClock = YES;
        cell.clockView.hidden = shouldHiddeClock;
        
        NSDateFormatter *absenceDateFormater = [[NSDateFormatter alloc] init];
        absenceDateFormater.dateFormat = @"YYYY-MM-dd";
        
        NSDateFormatter *latesDateFormater = [[NSDateFormatter alloc] init];
        latesDateFormater.dateFormat = @"HH:mm";
        
        NSMutableString *hours = [[NSMutableString alloc] initWithString:@""];
        
        void(^setAbsences)(void) = ^(void) {
            cell.clockView.color = MAIN_RED_COLOR;
            
            [user.absences enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
                RMAbsence *absence = (RMAbsence *)obj;
                
                if ((currentListState != ListStateOutTomorrow && [absence.isTomorrow boolValue] == NO)
                    ||
                    (currentListState == ListStateOutTomorrow && [absence.isTomorrow boolValue] == YES)
                    )
                {
                    shouldHiddeClock = NO;
                    NSString *start = [absenceDateFormater stringFromDate:absence.start];
                    NSString *stop = [absenceDateFormater stringFromDate:absence.stop];
                    
                    if (start.length || stop.length)
                    {
                        [hours appendFormat:@" %@  -  %@\n", start.length ? start : @"...",
                         stop.length ? stop : @"..."];
                    }
                }
            }];
        };
        
        void(^setLates)(void) = ^(void) {
            cell.clockView.color = MAIN_YELLOW_COLOR;
            
            [user.lates enumerateObjectsUsingBlock:^(id obj, BOOL *_stop) {
                RMLate *late = (RMLate *)obj;
                
                if ((currentListState != ListStateOutTomorrow && [late.isTomorrow boolValue] == NO)
                    ||
                    (currentListState == ListStateOutTomorrow && [late.isTomorrow boolValue] == YES)
                    )
                {
                    shouldHiddeClock = NO;
                    NSString *start = [latesDateFormater stringFromDate:late.start];
                    NSString *stop = [latesDateFormater stringFromDate:late.stop];
                    
                    if (start.length || stop.length)
                    {
                        [hours appendFormat:@" %@ - %@\n", start.length ? start : @"...",
                         stop.length ? stop : @"..."];
                    }
                }
            }];
        };
        
        if (currentListState == ListStateAll)
        {
            if (user.lates.count)
            {
                setLates();
            }
            else if (user.absences.count)
            {
                setAbsences();
            }
        }
        else
        {
            if (realSection == 1 || realSection == 2)
            {
                setLates();
            }
            else if (realSection == 0)
            {
                setAbsences();
            }
        }
        
        [hours setString:[hours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        cell.clockView.hidden = shouldHiddeClock;
        cell.warningDateLabel.text = hours;
    }
    
    if (user.avatarURL)
    {
        BOOL refresh = [avatarsToRefresh containsObject:user.id];
        [cell.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:user.avatarURL]
                                       forceRefresh:refresh];
        
        if (refresh)
        {
            [avatarsToRefresh removeObject:user.id];
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number;
    NSInteger count = 1;
    
    if (currentListState == ListStateAll)
    {
        number = userList.count;
    }
    else
    {
        number = [userList[section] count];
        count = [userList[0] count] + [userList[1] count] + [userList[2] count];
    }
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (currentListState == ListStateAll)
    {
        return 1;
    }
    else
    {
        return [self numberOfNotEmptySections];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (currentListState != ListStateAll)
    {
        NSInteger realSection = [self realSectionForNotEmptySection:section];
        
        switch (realSection)
        {
            case 0:
                return @"ABSENCE / HOLIDAY";
                
            case 1:
                return @"WORK FROM HOME";
                
            case 2:
                return @"OUT OF OFFICE";
        }
    }
    
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.rowHeight;
}

- (NSInteger)realSectionForNotEmptySection:(NSInteger)section
{
    if (currentListState == ListStateAll)
    {
        return section;
    }
    
    NSInteger result = -1;
    
    for (NSArray *array in userList)
    {
        result++;
        [array count] ? section--: section;

        if (section < 0)
            break;
    }
 
    return result;
}

- (NSInteger)numberOfNotEmptySections
{
    int result = 0;
    
    for (NSArray *array in userList)
    {
        [array count]  ? result++ : result;
    }
 
    return result;
}

#pragma mark - UISearchController

- (void)reloadSearchWithText:(NSString *)text
{
    canShowNoResultsMessage = NO;
    [self showNoSelectionUserDetails];
    searchedString = text;
    
    [self loadUsersFromDatabase];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self reloadSearchWithText:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self reloadSearchWithText:@""];
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
        if (INTERFACE_IS_PHONE)
        {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"New request" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Absence / Holiday", @"Out of office", nil];
            
            [actionSheet showFromTabBar:self.tabBarController.tabBar];

        }
        else
        {
            [self.requestActionSheet dismissWithClickedButtonIndex:20 animated:NO];
            [self.popover dismissPopoverAnimated:NO];
            
            self.requestActionSheet = [[UIActionSheet alloc] initWithTitle:@"New request" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Absence / Holiday", @"Out of office", nil];

            
            [self.requestActionSheet showFromBarButtonItem:self.addRequestButton animated:YES];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < 2)
    {
        if (INTERFACE_IS_PHONE)
        {
            UINavigationController *nvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddOOOFormTableViewControllerId"];
            
            [self presentViewController:nvc animated:YES completion:nil];
            
            AddOOOFormTableViewController *form = [nvc.viewControllers firstObject];
            form.currentRequest = (int)buttonIndex;
        }
        else
        {
            UINavigationController *nvc = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"AddOOOFormTableViewControllerId"];
            
            AddOOOFormTableViewController *outOfOfficeForm = [nvc.viewControllers firstObject];
            outOfOfficeForm.currentRequest = (int)buttonIndex;
            
            if (INTERFACE_IS_PAD)
            {
                self.popover = [[UIPopoverController alloc] initWithContentViewController:nvc];
                self.popover.delegate = self;
                
                if (iOS8_PLUS)
                {
                    [self performBlockOnMainThread:^{ //hack, popover don't show on ios 8
                        [self.popover presentPopoverFromBarButtonItem:self.addRequestButton
                                             permittedArrowDirections:UIPopoverArrowDirectionUp
                                                             animated:NO];
                        outOfOfficeForm.popover = self.popover;
                    } afterDelay:0];
                }
                else
                {
                    [self.popover presentPopoverFromBarButtonItem:self.addRequestButton
                                         permittedArrowDirections:UIPopoverArrowDirectionUp
                                                         animated:NO];
                    outOfOfficeForm.popover = self.popover;
                }
            }
            else
            {
                [self presentViewController:nvc animated:YES completion:nil];
            }
        }
    }
}

#pragma mark - Storyboard

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
        
        if (currentListState == ListStateAll)
        {
            ((UserDetailsTableViewController *)segue.destinationViewController).user = userList[indexPath.row];
        }
        else
        {
            NSInteger realSection = [self realSectionForNotEmptySection:indexPath.section];
            
            if (realSection == 0)
            {
                ((UserDetailsTableViewController *)segue.destinationViewController).isComeFromAbsences = YES;
            }
            
            ((UserDetailsTableViewController *)segue.destinationViewController).user = userList[realSection][indexPath.row];
        }
        
        ((UserDetailsTableViewController *)segue.destinationViewController).isListStateTommorow = currentListState == ListStateOutTomorrow;
    }
}

#pragma mark - iPad

- (void)showNoSelectionUserDetails
{
    if (INTERFACE_IS_PAD)
    {
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"NoSelectionUserDetails"];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
        nvc.navigationBar.tintColor = MAIN_APP_COLOR;
        
        self.splitViewController.viewControllers = @[self.splitViewController.viewControllers[0], nvc];
    }
}

@end
