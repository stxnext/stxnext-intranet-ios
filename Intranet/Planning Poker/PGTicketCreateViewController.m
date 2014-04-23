//
//  PGTicketCreateViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 08/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGTicketCreateViewController.h"
#import "UIViewController+PGSessionRuntime.h"
#import "PGEstimationResultsViewController.h"
#import "AppDelegate+RESideMenu.h"

@implementation PGTicketCreateViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _ticketName = @"";
    [self.tableView reloadData];
    
    [self markTextFieldAsFirstResponder:YES];
    
    [self prepareForGameSession];
    
    __weak typeof(self) weakSelf = self;
    
    [self addQuickObserverForNotificationWithKey:kAppDelegateNotificationRESideMenuWillShow withBlock:^(NSNotification *note) {
        [weakSelf markTextFieldAsFirstResponder:NO];
    }];
    
    [self addQuickObserverForNotificationWithKey:kAppDelegateNotificationRESideMenuWillHide withBlock:^(NSNotification *note) {
        [weakSelf markTextFieldAsFirstResponder:YES];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[GameManager defaultManager] joinActiveSessionWithCompletionHandler:^(GameManager *manager, NSError *error) { }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self markTextFieldAsFirstResponder:NO];
    
    [self removeQuickObservers];
    [self dismissParticipants];
}

#pragma mark - Navigation segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (_ticketName.length == 0)
    {
        [UIAlertView showWithTitle:@"Validation failed" message:@"No ticket name choosen." handler:nil];
        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[PGEstimationResultsViewController class]])
    {
        GMTicket* ticket = [GMTicket new];
        ticket.displayValue = _ticketName;
        
        [[GameManager defaultManager] startRoundWithTicket:ticket inActiveSessionWithCompletionHandler:^(GameManager *manager, NSError *error) {
            
        }];
    }
}

#pragma mark - First responder

- (void)markTextFieldAsFirstResponder:(BOOL)mark
{
    PGTicketCreateCell* cell = (PGTicketCreateCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (mark)
        [cell.inputTextField becomeFirstResponder];
    else
        [cell.inputTextField resignFirstResponder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"TICKET NAME";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* textCellIdentifier = @"inputCellIdentifier";
    
    PGTicketCreateCell* cell = [tableView dequeueReusableCellWithIdentifier:textCellIdentifier] ?:
    [[PGTicketCreateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellIdentifier];
    
    cell.inputTextField.text = _ticketName;
    
    [cell.inputTextField bk_removeEventHandlersForControlEvents:UIControlEventEditingChanged];
    [cell.inputTextField bk_addEventHandler:^(id sender) {
        UITextField* textField = sender;
        _ticketName = textField.text;
    } forControlEvents:UIControlEventEditingChanged];
    
    return cell;
}

@end

@implementation PGTicketCreateCell

@end