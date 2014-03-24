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

#import "Model.h"

@interface OutOfOfficeTodayTableViewController ()
{
    NSIndexPath *currentIndexPath;
}

@end

@implementation OutOfOfficeTodayTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.title = @"Out";
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refresh"];
    [refresh addTarget:self action:@selector(downloadPresences)forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    [self.tableView registerNib:[UINib nibWithNibName:@"UserListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[UserListCell cellId]];
    [self.tableView hideEmptySeparators];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self loadPresences];
}

#pragma mark - Presences

- (void)downloadPresences
{    
    [[Presences singleton] downloadPresencesWithStart:^(NSDictionary *params) {
        
//        [self.refreshControl endRefreshing];
//        self.tableView.hidden = YES;
        [LoaderView showWithRefreshControl:self.refreshControl tableView:self.tableView];
        
    } end:^(NSDictionary *params) {
        
        [self.tableView reloadData];
//        self.tableView.hidden = NO;
        [LoaderView hideWithRefreshControl:self.refreshControl tableView:self.tableView];
        
    } success:^(NSArray *presences) {
        
        _userList = presences;
        
    } failure:^(NSDictionary *data) {
        
    }];
}

- (void)loadPresences
{
    [[Presences singleton] presencesWithStart:^(NSDictionary *params) {
        
//        [self.refreshControl endRefreshing];
//        self.tableView.hidden = YES;
        [LoaderView showWithRefreshControl:self.refreshControl tableView:self.tableView];

    } end:^(NSDictionary *params) {
        
        [self.tableView reloadData];
//        self.tableView.hidden = NO;
        [LoaderView hideWithRefreshControl:self.refreshControl tableView:self.tableView];
        
    } success:^(NSArray *presences) {
        
        _userList = presences;
        
    } failure:^(NSDictionary *data) {
        
    }];
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
        [UIAlertView showInfoWithMessage:@"Nothing to show." handler:nil];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetailsTableViewController *userDetailsTVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"UserDetailsTableViewControllerId"];
    
    currentIndexPath = indexPath;
    
    userDetailsTVC.user = _userList[indexPath.section][indexPath.row];
    
    [self.navigationController pushViewController:userDetailsTVC animated:YES];
}

#pragma mark - Storyboard

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
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
     */
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"AddOOOFormTableViewControllerId"] && ![[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        [UIAlertView showErrorWithMessage:@"No Internet connection." handler:nil];
        
        return NO;
    }
    
    return YES;
}

@end
