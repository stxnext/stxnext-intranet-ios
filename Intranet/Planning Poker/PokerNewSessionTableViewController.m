//
//  NewPokerSessionTableViewController.m
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PokerNewSessionTableViewController.h"

typedef NS_ENUM(NSUInteger, InputType)
{
    InputTypeTitle,
    InputTypeSummary,
    InputTypeTicket,
    InputTypeTicketEdit
};

@interface PokerNewSessionTableViewController ()

@end

@implementation PokerNewSessionTableViewController

- (void)viewDidLoad
{
    if (!self.pokerSession)
    {
        self.pokerSession = [[PokerSession alloc] init];
        self.pokerSession.date = [NSDate date];
    }

    isDatePickerHidden = YES;
    
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
            
        case PokerSessionTypeEdit:
        {
            self.title = @"Edit Poker";
        }
            break;
    }
    
    [super viewDidLoad];
    
    if (self.pokerSessionType != PokerSessionTypeEdit)
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(cancel)];
        
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                               target:self
                                                                                               action:@selector(save)];
    }
    
    [self.tableView hideEmptySeparators];
}

- (void)cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)save
{
    if ([self.delegate respondsToSelector:@selector(pokerNewSessionTableViewController:didFinishWithPokerSession:)])
    {
        [self.delegate pokerNewSessionTableViewController:self didFinishWithPokerSession:self.pokerSession];

        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.pokerSessionType == PokerSessionTypeEdit && ![self.navigationController.viewControllers containsObject:self])
    {
        if ([self.delegate respondsToSelector:@selector(pokerNewSessionTableViewController:didFinishWithPokerSession:)])
        {            
            [self.delegate pokerNewSessionTableViewController:self didFinishWithPokerSession:self.pokerSession];
            [self.navigationController popViewControllerAnimated:YES];;
        }
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.pokerSessionType == PokerSessionTypeNormal || self.pokerSession.tickets.count ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return self.pokerSessionType == PokerSessionTypeNormal || self.pokerSession.tickets.count  ? 6 : 4;
            
        case 1:
            return 1 + self.pokerSession.tickets.count;

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
                    cell.textLabel.text = @"Players";
                    cell.detailTextLabel.text = self.pokerSession.teamTitle;
                }
                    break;
                    
                case 4:
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.textLabel.text = @"Date";
                    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
                    dateFormater.dateFormat = @"dd/MM/YYYY HH:mm";
                    cell.detailTextLabel.text = [dateFormater stringFromDate:self.pokerSession.date];
                }
                    break;
                    
                case 5:
                {
                    static NSString *pickerCellId = @"DateCellId";
                    
                    cell = [tableView dequeueReusableCellWithIdentifier:pickerCellId];
                    
                    if (cell == nil)
                    {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:pickerCellId];
                    }
                    
                    if (!datePicker)
                    {
                        [cell performBlockOnAllSubviews:^(UIView *view) {
                            if ([view isKindOfClass:[UIDatePicker class]])
                            {
                                datePicker = (UIDatePicker *)view;
                                datePicker.minimumDate = [NSDate date];
                                [datePicker addTarget:self action:@selector(dateTimeValueChanged:) forControlEvents:UIControlEventValueChanged];
                            }
                        }];
                    }
                    
                    datePicker.date = self.pokerSession.date;
                }
                    break;

            }
        }
            break;
            
            
        case 1:
        {
            if (indexPath.row == 0/*self.pokerSession.tickets.count*/)
            {
                return [tableView dequeueReusableCellWithIdentifier:@"newTicketCellID"];
            }
            else
            {
                cell.textLabel.text = self.pokerSession.tickets[indexPath.row-1];
            }

        }
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 5 && indexPath.section == 0)
    {
        return isDatePickerHidden ? 0 : 162;
    }
    
    return self.tableView.rowHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"Basics";
            
        case 1:
            return @"Tickets";
    }
    
    return @"";
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
                    textInputVC.type = indexPath.row == 0 ? InputTypeTitle : InputTypeSummary;
                    textInputVC.inputText = indexPath.row == 0 ? self.pokerSession.title : self.pokerSession.summary;
                    
                    textInputVC.delegate = self;
                    
                    [self.navigationController pushViewController:textInputVC animated:YES];
                }
                    break;
                    
                case 2:
                {
                    CardsTypeTableViewController *cardsTypeVC = [[UIStoryboard storyboardWithName:@"CardTypeStoryboard" bundle:nil] instantiateInitialViewController];
                    
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
                    teamsVC.delegate = self;
                    teamsVC.previousSelectedUsers = self.pokerSession.teamUsersIDs;
                    teamsVC.previousSelectedTeamId = self.pokerSession.teamID;
                    
                    [self.navigationController pushViewController:teamsVC animated:YES];
                }
                    break;
                    
                case 4:
                {
                    isDatePickerHidden = !isDatePickerHidden;
                    [self.tableView reloadDataAnimated:YES];
                }
                    break;
                    
                case 5:
                {
                    
                }
                    break;

            }
        }
            break;
            
        case 1:
        {
            if (indexPath.row == 0)
            {
                TextInputViewController *textInputVC = [[TextInputViewController alloc] initWithNibName:@"TextInputViewController" bundle:nil];
                
                textInputVC.title = @"New Ticket";
                textInputVC.type = InputTypeTicket;
                
                textInputVC.delegate = self;
                
                [self.navigationController pushViewController:textInputVC animated:YES];
            }
            else
            {
                TextInputViewController *textInputVC = [[TextInputViewController alloc] initWithNibName:@"TextInputViewController" bundle:nil];
                
                textInputVC.title = @"New Ticket";
                textInputVC.type = InputTypeTicketEdit;
                
                itemToChange = indexPath.row - 1;
                
                textInputVC.inputText = self.pokerSession.tickets[itemToChange];
                
                textInputVC.delegate = self;
                
                [self.navigationController pushViewController:textInputVC animated:YES];
            }
            
        }
            break;
    }
}

#pragma mark - TextInputViewControllerDelegate

- (void)textInputViewController:(TextInputViewController *)textInputViewController didFinishWithResult:(NSString *)result
{    
    if (result.length)
    {
        switch (textInputViewController.type)
        {
            case InputTypeTitle:
            {
                self.pokerSession.title = result;
            }
                break;
                
            case InputTypeSummary:
            {
                self.pokerSession.summary = result;
            }
                break;
                
            case InputTypeTicket:
            {
                [self.pokerSession.tickets addObject:result];
            }
                break;
                
            case InputTypeTicketEdit:
            {
                [self.pokerSession.tickets replaceObjectAtIndex:itemToChange withObject:result];
            }
                break;
        }
        
        [self.tableView reloadDataAnimated:YES];
    }
}

#pragma mark - CardsTypeTableViewControllerDelegate

- (void)cardsTypeTableViewController:(CardsTypeTableViewController *)cardsTypeTableViewController
                 didFinishWithValues:(NSArray *)values
                    cardsValuesTitle:(NSString *)title
{
    self.pokerSession.cardValues = values;
    self.pokerSession.cardValuesTitle = title;
    
    [self.tableView reloadDataAnimated:YES];
}

#pragma mark - TeamsTableViewControllerDelegate

- (void)teamsTableViewController:(TeamsTableViewController *)teamsTableViewController
                didFinishWithIDs:(NSArray *)values
                       teamTitle:(NSString *)title
                          teamId:(NSNumber *)teamId
{
    self.pokerSession.teamUsersIDs = values;
    self.pokerSession.teamTitle = title;
    self.pokerSession.teamID = teamId;
    
    [self.tableView reloadDataAnimated:YES];
}


- (void)dateTimeValueChanged:(UIDatePicker *)sender
{
    self.pokerSession.date = sender.date;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

@end
