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
@interface OutOfOfficeTodayTableViewController ()
{
    NSIndexPath *currentIndexPath;
}

@end

@implementation OutOfOfficeTodayTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Out";
    
    [self.tableView hideEmptySeparators];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self loadUsersFromDatabase];
}

- (void)loadUsersFromDatabase
{
    DDLogInfo(@"Loading from: Database");
    
    NSArray *users = [JSONSerializationHelper objectsWithClass:[RMUser class]
                                            withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                             ascending:YES
                                                                                              selector:@selector(localizedCompare:)]
                                                 withPredicate:[NSPredicate predicateWithFormat:@"isActive = YES"]
                                              inManagedContext:[DatabaseManager sharedManager].managedObjectContext];

    _userList = [[NSMutableArray alloc] init];
    
    [_userList addObject:[users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClient = NO AND isFreelancer = NO && absences.@count > 0"]] ?:[[NSArray alloc] init]];
    
    [_userList addObject:[users filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        RMUser *user = (RMUser *)evaluatedObject;

        if ([user.isClient boolValue] == YES || [user.isFreelancer boolValue] == YES)
        {
            return NO;
        }
        
        if (user.lates.count)
        {
            for (RMLate *late in user.lates)
            {
                if ([late.isWorkingFromHome intValue] == 1)
                {
                    return YES;
                }
            }
        }
        
        return NO;
    }]]?:[[NSArray alloc] init]];
    
    [_userList addObject:[users filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        RMUser *user = (RMUser *)evaluatedObject;
        
        if ([user.isClient boolValue] == YES || [user.isFreelancer boolValue] == YES)
        {
            return NO;
        }
        
        if (user.lates.count)
        {
            for (RMLate *late in user.lates)
            {
                if ([late.isWorkingFromHome intValue] == 0)
                {
                    return YES;
                }
            }
        }
        
        return NO;
    }]]?:[[NSArray alloc] init]];

    
    [self.tableView reloadData];
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
    
    if (count == 0)
    {
        [UIAlertView showWithTitle:@"Info"
                           message:@"Nothing to show."
                             style:UIAlertViewStyleDefault
                 cancelButtonTitle:nil
                 otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                 }];
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
                [hours appendFormat:@" %@ - %@", start.length ? start : @"...",
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
                [hours appendFormat:@" %@  -  %@", start.length ? start : @"...",
                 stop.length ? stop : @"..."];
            }
        }];
    }
    
    [hours setString:[hours stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    cell.warningDateLabel.text = hours;
    
    if (user.avatarURL)
    {
        [cell.userImage setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:user.avatarURL]];
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

@end
