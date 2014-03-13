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
                    CardsTypeTableViewController *cardsTypeVC = [[UIStoryboard storyboardWithName:@"CardTypeStoryboard" bundle:nil] instantiateInitialViewController];
                    
//                    [[CardsTypeTableViewController alloc] initWithNibName:@"CardsTypeTableViewController" bundle:nil];
                    cardsTypeVC.title = @"Cards";
                    cardsTypeVC.selectedCardsValuesTitle = self.pokerSession.cardValuesTitle;

                    if ([self.pokerSession.cardValuesTitle isEqualToString:CustomTitle])
                    {
                        NSMutableString *cardValues = [[NSMutableString alloc] initWithString:@""];
                        
                        for (NSString *value in self.pokerSession.cardValues)
                        {
                            [cardValues appendFormat:@"%@, ", value];
                        }
                        
                        if (cardValues.length > 2)
                        {
                            cardsTypeVC.customCardValues = [cardValues substringWithRange:NSMakeRange(0, cardValues.length-2)];
                        }
                    }
                    
                    cardsTypeVC.delegate = self;
                    
                    [self.navigationController pushViewController:cardsTypeVC animated:YES];
                }
                    break;
                    
                case 3:
                {
                    TeamsTableViewController *teamsVC = [[UIStoryboard storyboardWithName:@"TeamsStoryboard" bundle:nil] instantiateInitialViewController];
                    teamsVC.title = @"Team";
                    
                    [self.navigationController pushViewController:teamsVC animated:YES];
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

#pragma mark - CardsTypeTableViewControllerDelegate

- (void)cardsTypeTableViewController:(CardsTypeTableViewController *)cardsTypeTableViewController
                 didFinishWithValues:(NSArray *)values
                    cardsValuesTitle:(NSString *)title
{
    DDLogCError(@"TITLE %@", title);
    DDLogCError(@"VALUES %@", values);
    
    self.pokerSession.cardValues = values;
    self.pokerSession.cardValuesTitle = title;
    
    [self.tableView reloadDataAnimated:YES];
}

@end
