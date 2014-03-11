//
//  NewPokerSessionTableViewController.m
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PokerNewSessionTableViewController.h"

typedef NS_ENUM(NSUInteger, BasicInfo)
{
    BasicInfoTitle,
    BasicInfoSummary
};

@interface PokerNewSessionTableViewController ()

@end

@implementation PokerNewSessionTableViewController

- (void)viewDidLoad
{
    self.pokerSession = [[PokerSession alloc] init];
    
    switch (self.pokerSessionType)
    {
        case PokerSessionTypeQuick:
        {
            self.title = @"New Quick Poker";
        }
            break;
            
        case PokerSessionTypeNormal:
        {
            self.title = @"New Poker";
        }
            break;
    }
    
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
    
    [self.tableView hideEmptySeparators];
}

- (void)cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)save
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.pokerSessionType == PokerSessionTypeNormal ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return self.pokerSessionType == PokerSessionTypeNormal ? 5 : 4;
            
        case 1:
            return 1;

        default:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *defaultCellId = @"defaultCellId";

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:defaultCellId];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:defaultCellId];
    }

    switch (indexPath.section)
    {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            switch (indexPath.row)
            {
                case 0:
                {
                    cell.textLabel.text = @"Title";
                    cell.detailTextLabel.text = self.pokerSession.title;
                }
                    break;

                case 1:
                {
                    cell.textLabel.text = @"Summary";
                    cell.detailTextLabel.text = self.pokerSession.summary;
                }
                    break;

                case 2:
                {
                    cell.textLabel.text = @"Cards type";
                    cell.detailTextLabel.text = self.pokerSession.cardValuesTitle;
                }
                    break;

                case 3:
                {
                    cell.textLabel.text = @"Team";
                    cell.detailTextLabel.text = self.pokerSession.teamIDsTitle;
                }
                    break;
                    
                case 4:
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.textLabel.text = @"Date";
                    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                    dateFormater.dateFormat = @"dd/MM/YYYY";
                    cell.detailTextLabel.text = [dateFormater stringFromDate:self.pokerSession.date];
                }
                    break;
            }
        }
            break;
            
        case 1:
        {
            if (indexPath.row == self.ticketList.count)
            {
                return [tableView dequeueReusableCellWithIdentifier:@"newTicketCellID"];
            }

        }
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"Basics";
            
        case 1:
            return @"Tickets";
            
        default:
            return @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            //TextInputViewController
            switch (indexPath.row)
            {
                case 0:
                case 1:
                {
                    TextInputViewController *textInputVC = [[TextInputViewController alloc] initWithNibName:@"TextInputViewController" bundle:nil];

                    textInputVC.title = indexPath.row == 0 ? @"Title" : @"Description";
                    textInputVC.type = indexPath.row == 0 ? BasicInfoTitle : BasicInfoSummary;
                    textInputVC.inputText = indexPath.row == 0 ? self.pokerSession.title : self.pokerSession.summary;
                    
                    textInputVC.delegate = self;
                    
                    [self.navigationController pushViewController:textInputVC animated:YES];
                }
                    break;
                    
                case 2:
                {
                    CardsTypeTableViewController *cardsTypeVC = [[CardsTypeTableViewController alloc] initWithNibName:@"CardsTypeTableViewController" bundle:nil];
                    cardsTypeVC.title = @"Cards";
                    
                    [self.navigationController pushViewController:cardsTypeVC animated:YES];
                }
                    break;
                    
                case 3:
                {
                    
                }
                    break;
                    
                case 4:
                {
                    
                }
                    break;
            }
        }
            break;
            
        case 1:
        {
            
        }
            break;
    }
}




/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - TextInputViewControllerDelegate

- (void)textInputViewController:(TextInputViewController *)textInputViewController didFinishWithResult:(NSString *)result
{
    switch (textInputViewController.type)
    {
        case BasicInfoTitle:
        {
            self.pokerSession.title = result;
        }
            break;
            
        case BasicInfoSummary:
        {
            self.pokerSession.summary = result;
        }
            break;
    }
    
    [self.tableView reloadDataAnimated:YES];
}

@end
