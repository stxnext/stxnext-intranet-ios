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
#import "OutOfOfficeManager.h"

#import "Model.h"

@interface OutOfOfficeTodayTableViewController ()
{
    NSIndexPath *currentIndexPath;
}

@property (nonatomic, strong) OutOfOfficeManager *holidayUsersManager;
@property (nonatomic, strong) OutOfOfficeManager *workFromHomeUsersManager;
@property (nonatomic, strong) OutOfOfficeManager *outOfOfficeUsersManager;

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
        
        [LoaderView showWithRefreshControl:self.refreshControl tableView:self.tableView];
        
    } end:^(NSDictionary *params) {
        
        [self.tableView reloadData];
        [LoaderView hideWithRefreshControl:self.refreshControl tableView:self.tableView];
        
    } success:^(NSArray *presences) {
        
        [self addUsers:presences];
        
    } failure:^(NSDictionary *data) {
        
    }];
}

- (void)loadPresences
{
    [[Presences singleton] presencesWithStart:^(NSDictionary *params) {
        
        [LoaderView showWithRefreshControl:self.refreshControl tableView:self.tableView];

    } end:^(NSDictionary *params) {
        
        [self.tableView reloadData];
        [LoaderView hideWithRefreshControl:self.refreshControl tableView:self.tableView];
        
    } success:^(NSArray *presences) {
        
        [self addUsers:presences];
        
    } failure:^(NSDictionary *data) {
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfUserManagers];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self userManagerForSection:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMUser *user = [[self userManagerForSection:indexPath.section] userAtIndex:indexPath.row];
    
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
    
    if ([self userManagerForSection:indexPath.section] != self.holidayUsersManager)
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
    else
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
    return [self titleForUserManagerAtSection:section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserDetailsTableViewController *userDetailsTVC = [[self storyboard] instantiateViewControllerWithIdentifier:@"UserDetailsTableViewControllerId"];
    
    currentIndexPath = indexPath;
    
    userDetailsTVC.user = [[self userManagerForSection:indexPath.section] userAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:userDetailsTVC animated:YES];
}

#pragma mark - Storyboard

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"AddOOOFormTableViewControllerId"] && ![[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        [UIAlertView showErrorWithMessage:@"No Internet connection." handler:nil];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - OutOfOfficeManagers

- (void)addUsers:(NSArray *)users
{
    self.holidayUsersManager = [OutOfOfficeManager new];
    self.workFromHomeUsersManager = [OutOfOfficeManager new];
    self.outOfOfficeUsersManager = [OutOfOfficeManager new];

    int i = 0;
    
    for (NSArray *usersArray in users)
    {
        for (RMUser *user in usersArray)
        {
            switch (i)
            {
                case 0:
                {
                    [self.holidayUsersManager addUser:user];
                }
                    break;
                    
                case 1:
                {
                    [self.workFromHomeUsersManager addUser:user];
                }
                    break;

                case 2:
                {
                    [self.outOfOfficeUsersManager addUser:user];
                }
                    break;
            }
        }
        
        i++;
    }
}

- (OutOfOfficeManager *)userManagerForSection:(NSUInteger)section
{
    int curr = -1;
    
    if (self.holidayUsersManager.count)
    {
        curr++;
        
        if (curr == section)
        {
            return self.holidayUsersManager;
        }
    }
    
    if (self.workFromHomeUsersManager.count)
    {
        curr++;
        
        if (curr == section)
        {
            return self.workFromHomeUsersManager;
        }
    }
    
    if (self.outOfOfficeUsersManager.count)
    {
        curr++;
        
        if (curr == section)
        {
            return self.outOfOfficeUsersManager;
        }
    }
    
    return nil;
}

- (int)numberOfUserManagers
{
    int result = 0;
    
    if (self.holidayUsersManager.count)
    {
        result++;
    }
    
    if (self.workFromHomeUsersManager.count)
    {
        result++;
    }
    
    if (self.outOfOfficeUsersManager.count)
    {
        result++;
    }
    
    return result;
}

- (NSString *)titleForUserManagerAtSection:(NSInteger)section
{
    if ([self userManagerForSection:section] == self.holidayUsersManager)
    {
        return @"Absence / Holiday";
    }
    else if ([self userManagerForSection:section] == self.workFromHomeUsersManager)
    {
        return @"Work From Home";
    }
    else if ([self userManagerForSection:section] == self.outOfOfficeUsersManager)
    {
        return @"Out of Office";
    }
    
    return nil;
}

@end
