//
//  PGSessionCreateViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 28/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGSessionCreateViewController.h"
#import "UIListPicker.h"

typedef enum SessionCreationCells {
    SessionCreationCellName = 0,
    SessionCreationCellDeck,
    SessionCreationCellDeckPicker,
    SessionCreationCellDate,
    SessionCreationCellDatePicker,
    SessionCreationCellPlayers,
    SessionCreationCellsCount
} SessionCreationCells;

@implementation PGSessionCreateViewController

- (void)viewDidLoad
{
    _isDeckPickerVisible = NO;
    _isDatePickerVisible = NO;
    
    _session = [GMSession new];
    _session.startTime = [NSDate date].mapToTime;
    _session.deckId = ((GMDeck*)[GameManager defaultManager].decks.firstObject).identifier;
    _session.owner = [GameManager defaultManager].user;
    
    [self.tableView hideEmptySeparators];
}

#pragma mark - Table dropdowns

- (void)changeVisibilityForDropdownAtCellIdentifier:(SessionCreationCells)cellIdentifier
{
    switch (cellIdentifier)
    {
        case SessionCreationCellDeck:
            _isDeckPickerVisible = !_isDeckPickerVisible;
            _isDatePickerVisible = NO;
            break;
        case SessionCreationCellDate:
            _isDatePickerVisible = !_isDatePickerVisible;
            _isDeckPickerVisible = NO;
            break;
            
        default: break;
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

#pragma mark - Navigation segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.destinationViewController isKindOfClass:[PGPlayerPickerViewController class]])
    {
        PGPlayerPickerViewController* playerController = segue.destinationViewController;
        playerController.delegate = self;
        playerController.selectedPlayers = [NSSet setWithArray:self.session.players];
    }
}

#pragma mark - Player picker delegate

- (void)playerPickerViewController:(PGPlayerPickerViewController*)playerPickerViewController didFinishWithPlayers:(NSSet*)players
{
    self.session.players = players.allObjects;
    [self.tableView reloadData];
}

#pragma mark - User actions

- (IBAction)save
{
    static NSString* validationDomain = @"Validation failed";
    
    if (self.session.name.length == 0)
        [UIAlertView showWithTitle:validationDomain message:@"Invalid session name." handler:nil];
    else if (self.session.players.count == 0)
        [UIAlertView showWithTitle:validationDomain message:@"No players selected." handler:nil];
    else
    {
        [[GameManager defaultManager] connectedClientWithCompletionHandler:^(GameClient *client, NSError* error, dispatch_block_t disconnectCallback) {
            if (error)
            {
                [UIAlertView showWithTitle:@"Server problem" message:@"Could not connect to game server." handler:nil];
                return;
            }
            
            [client createSessionWithName:self.session.name
                                     deck:self.session.deck
                                  players:[self.session.players valueForKey:@"mapToGMUser"]
                                    owner:self.session.owner
                                startDate:self.session.startTime.mapToDate
                        completionHandler:^(GMSession *session, NSError *error) {
                            disconnectCallback();
                            
                            if (error)
                            {
                                [UIAlertView showWithTitle:@"Server problem" message:@"Could not create session on game server." handler:nil];
                                return;
                            }
                            
                            [self.navigationController popViewControllerAnimated:YES];
                        }];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return SessionCreationCellsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* textCellIdentifier = @"textCellIdentifier";
    static NSString* dateCellIdentifier = @"dateCellIdentifier";
    static NSString* pickerCellIdentifier = @"pickerCellIdentifier";
    static NSString* playersCellIdentifier = @"playersCellIdentifier";
    
    UITableViewCell* cell = nil;
    
    switch (indexPath.row)
    {
        case SessionCreationCellName:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:textCellIdentifier] ?:
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:textCellIdentifier];
            
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.session.name;
            
            break;
        }
        
        case SessionCreationCellDeck:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:textCellIdentifier] ?:
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:textCellIdentifier];
            
            cell.textLabel.text = @"Deck";
            cell.detailTextLabel.text = self.session.deck.name;
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            break;
        }
            
        case SessionCreationCellDeckPicker:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:pickerCellIdentifier] ?:
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:pickerCellIdentifier];
            
            [cell performBlockOnAllSubviews:^(UIView *view) {
                if ([view isKindOfClass:[UIListPicker class]])
                {
                    UIListPicker* deckPicker = (UIListPicker*)view;
                    
                    [deckPicker setPickerElementsList:[GameManager defaultManager].decks
                                  withSelectedElement:self.session.deck
                                withElementNameMapper:^NSString *(id element) {
                                    GMDeck* deck = element;
                                    return deck.name;
                                }
                           withSelectionChangeHandler:^(UIListPicker *picker, id selectedElement) {
                               GMDeck* deck = selectedElement;
                               self.session.deckId = deck.identifier;
                               
                               [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:SessionCreationCellDeck inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                               [self changeVisibilityForDropdownAtCellIdentifier:SessionCreationCellDeck];
                           }];
                }
            }];
            
            break;
        }
            
        case SessionCreationCellDate:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:textCellIdentifier] ?:
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:textCellIdentifier];
            
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
            dateFormater.dateFormat = @"dd/MM/YYYY HH:mm";
            
            cell.textLabel.text = @"Date";
            cell.detailTextLabel.text = [dateFormater stringFromDate:self.session.startTime.mapToDate];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            break;
        }
            
        case SessionCreationCellDatePicker:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:dateCellIdentifier] ?:
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:dateCellIdentifier];
            
            [cell performBlockOnAllSubviews:^(UIView *view) {
                if ([view isKindOfClass:[UIDatePicker class]])
                {
                    UIDatePicker* datePicker = (UIDatePicker*)view;
                    datePicker.minimumDate = [NSDate date];
                    [datePicker addTarget:self action:@selector(dateTimeValueChanged:) forControlEvents:UIControlEventValueChanged];
                }
            }];
            
            break;
        }
        
        case SessionCreationCellPlayers:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:playersCellIdentifier] ?:
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:playersCellIdentifier];
            
            cell.textLabel.text = @"Players";
            cell.detailTextLabel.text = self.session.players.count == 0 ? @"None" : [NSString stringWithFormat:@"%d", self.session.players.count];
            
            break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case SessionCreationCellDeckPicker: return _isDeckPickerVisible ? 90.0 : 0.0;
        case SessionCreationCellDatePicker: return _isDatePickerVisible ? 162.0 : 0.0;
            
        default: return self.tableView.rowHeight;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"SESSION INFORMATION";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row)
    {
        case SessionCreationCellName:
        {
            TextInputViewController* textInputController = [[TextInputViewController alloc] initWithNibName:@"TextInputViewController" bundle:nil];
            
            textInputController.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            textInputController.inputText = [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text;
            textInputController.type = indexPath.row;
            textInputController.delegate = self;
            
            [self.navigationController pushViewController:textInputController animated:YES];
            
            break;
        }
            
        case SessionCreationCellDeck:
        case SessionCreationCellDate:
        {
            [self changeVisibilityForDropdownAtCellIdentifier:indexPath.row];
            
            break;
        }
            
        case SessionCreationCellPlayers:
        {
            break;
        }
    }
}

#pragma mark - Date picker

- (void)dateTimeValueChanged:(UIDatePicker *)sender
{
    self.session.startTime = sender.date.mapToTime;
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:SessionCreationCellDate inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - TextInputViewControllerDelegate

- (void)textInputViewController:(TextInputViewController *)textInputViewController didFinishWithResult:(NSString *)result
{
    switch (textInputViewController.type)
    {
        case SessionCreationCellName:
        {
            self.session.name = result;
            break;
        }
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:textInputViewController.type inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

@end