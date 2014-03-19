//
//  PokerSessionsListTableViewController.m
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PokerSessionsListTableViewController.h"
#import "PokerSessionManager.h"

@interface PokerSessionsListTableViewController ()

@property (nonatomic, strong) PokerSessionManager *sessionsUpcommingSessions;
@property (nonatomic, strong) PokerSessionManager *sessionsNowSessions;
@property (nonatomic, strong) PokerSessionManager *sessionsCompletedSessions;

@end

@implementation PokerSessionsListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    PokerSession *testSession = [PokerSession new];
    [testSession fillWithTestData];

    self.sessionsUpcommingSessions = [PokerSessionManager new];
    self.sessionsNowSessions = [PokerSessionManager new];
    self.sessionsCompletedSessions = [PokerSessionManager new];
    
    [self.sessionsUpcommingSessions addPokerSession:testSession];
    [self.sessionsNowSessions addPokerSession:testSession];
    [self.sessionsCompletedSessions addPokerSession:testSession];
    
    [self.tableView hideEmptySeparators];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self numberOfSessionManagers];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self sessionManagerForSection:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self titleForSessionManagerAtSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId =  @"CellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text =  [[self sessionManagerForSection:indexPath.section] pokerSessionAtIndex:indexPath.row].title;
    cell.detailTextLabel.text =  [[self sessionManagerForSection:indexPath.section] pokerSessionAtIndex:indexPath.row].summary;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PokerSessionTableViewController *pokerNewSessionTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PokerNewSessionTableViewControllerId"];
    
    pokerNewSessionTVC.pokerSession = [[self sessionManagerForSection:indexPath.section] pokerSessionAtIndex:indexPath.row];

    pokerNewSessionTVC.pokerSessionType = PokerSessionTypePlay;
    pokerNewSessionTVC.delegate = self;
    
    [self.navigationController pushViewController:pokerNewSessionTVC animated:YES];
}

#pragma mark -  PokerSessionTableViewControllerDelegate

- (void)pokerSessionTableViewController:(PokerSessionTableViewController *)pokerSessionTableViewController didFinishWithPokerSession:(PokerSession *)pokerSession
{
    if (pokerSessionTableViewController.pokerSessionType == PokerSessionTypeEdit)
    {
        
    }
    else
    {
        [self.sessionsUpcommingSessions addPokerSession:pokerSession];
    }

    [self.tableView reloadDataAnimated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"QuickPokerId"])
    {
        PokerSessionTableViewController *pokerSesionVC = ((PokerSessionTableViewController *)((UINavigationController *)segue.destinationViewController).viewControllers[0]);
        
        pokerSesionVC.pokerSessionType = PokerSessionTypeNewQuick;
        pokerSesionVC.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"NormalPokerId"])
    {
        PokerSessionTableViewController *pokerSesionVC = ((PokerSessionTableViewController *)((UINavigationController *)segue.destinationViewController).viewControllers[0]);
        
        pokerSesionVC.pokerSessionType = PokerSessionTypeNewNormal;
        pokerSesionVC.delegate = self;
    }
}

#pragma mark - SessionManagers

- (PokerSessionManager *)sessionManagerForSection:(NSUInteger)section
{
    switch (section)
    {
        case 0:
        {
            if (self.sessionsUpcommingSessions.count)
            {
                return self.sessionsUpcommingSessions;
            }
            else if (self.sessionsNowSessions.count)
            {
                return self.sessionsNowSessions;
            }
            else if (self.sessionsCompletedSessions.count)
            {
                return self.sessionsCompletedSessions;
            }
        }
            break;

        case 1:
        {
            if (self.sessionsNowSessions.count)
            {
                return self.sessionsNowSessions;
            }
            else if (self.sessionsCompletedSessions.count)
            {
                return self.sessionsCompletedSessions;
            }
        }
            break;

        case 2:
        {
            if (self.sessionsCompletedSessions.count)
            {
                return self.sessionsCompletedSessions;
            }
        }
            break;

    }
    
    return nil;
}

- (int)numberOfSessionManagers
{
    int result = 0;

    if (self.sessionsUpcommingSessions.count)
    {
        result++;
    }
    
    if (self.sessionsNowSessions.count)
    {
        result++;
    }
    
    if (self.sessionsCompletedSessions.count)
    {
        result++;
    }
    
    return result;
}

- (NSString *)titleForSessionManagerAtSection:(NSInteger)section
{
    if ([self sessionManagerForSection:section] == self.sessionsUpcommingSessions)
    {
        return @"Upcoming";
    }
    else if ([self sessionManagerForSection:section] == self.sessionsNowSessions)
    {
        return @"Now";
    }
    else if ([self sessionManagerForSection:section] == self.sessionsCompletedSessions)
    {
        return @"Completed";
    }
    
    return nil;
}

@end
