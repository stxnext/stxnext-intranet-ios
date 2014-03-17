//
//  PokerSessionsListTableViewController.m
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PokerSessionsListTableViewController.h"

@interface PokerSessionsListTableViewController ()

@property (nonatomic, strong) NSArray *sessions;
@end

@implementation PokerSessionsListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sessions = @[[NSMutableArray new], [NSMutableArray new], [NSMutableArray new]];
    
    
    PokerSession *testSession = [PokerSession new];
    [testSession fillWithTestData];
    
    [self.sessions[0] addObject:testSession];
    [self.sessions[1] addObject:testSession];
    [self.sessions[2] addObject:testSession];
    
    [self.tableView hideEmptySeparators];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sessions[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"Upcoming";
            
        case 1:
            return @"Now";

        case 2:
            return @"Completed";
    }
    
    return @"";
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
    cell.textLabel.text = ((PokerSession *)self.sessions[indexPath.section][indexPath.row]).title;
    cell.detailTextLabel.text = ((PokerSession *)self.sessions[indexPath.section][indexPath.row]).summary;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PokerNewSessionTableViewController *pokerNewSessionTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PokerNewSessionTableViewControllerId"];
    pokerNewSessionTVC.pokerSession = self.sessions[indexPath.section][indexPath.row];
    pokerNewSessionTVC.pokerSessionType = PokerSessionTypeEdit;
    pokerNewSessionTVC.delegate = self;
    
    [self.navigationController pushViewController:pokerNewSessionTVC animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0;
}
//*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark -  PokerNewSessionTableViewControllerDelegate

- (void)pokerNewSessionTableViewController:(PokerNewSessionTableViewController *)pokerNewSessionTableViewController didFinishWithPokerSession:(PokerSession *)pokerSession
{
    if (pokerNewSessionTableViewController.pokerSessionType == PokerSessionTypeEdit)
    {
        
    }
    else
    {
        [self.sessions[0] addObject:pokerSession];
    }

    [self.tableView reloadDataAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"QuickPokerId"])
    {
       ((PokerNewSessionTableViewController *)((UINavigationController *)segue.destinationViewController).viewControllers[0]).pokerSessionType = PokerSessionTypeQuick;
        ((PokerNewSessionTableViewController *)((UINavigationController *)segue.destinationViewController).viewControllers[0]).delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"NormalPokerId"])
    {
        ((PokerNewSessionTableViewController *)((UINavigationController *)segue.destinationViewController).viewControllers[0]).pokerSessionType = PokerSessionTypeNormal;
        ((PokerNewSessionTableViewController *)((UINavigationController *)segue.destinationViewController).viewControllers[0]).delegate = self;
    }
}

@end
