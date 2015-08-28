//
//  OutOfOfficeTodayTableViewController.m
//  Intranet
//
//  Created by Adam on 19.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "OutOfOfficeTodayTableViewController.h"

@interface OutOfOfficeTodayTableViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end


@implementation OutOfOfficeTodayTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.absencesButton setTitle:NSLocalizedString(@"Holiday", nil) forState:UIControlStateNormal];
    [self.workFromHomeButton setTitle:NSLocalizedString(@"Work from Home", nil) forState:UIControlStateNormal];
    [self.outOfOfficeButton setTitle:NSLocalizedString(@"Out of Office", nil) forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartRefreshPeople) name:DID_START_REFRESH_PEOPLE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndRefreshPeople) name:DID_END_REFRESH_PEOPLE object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadUsersFromDatabase];
}

- (void)loadUsersFromDatabase
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:IS_REFRESH_PEOPLE])
    {
        if (userList.count == 0)
        {
            [self addActivityIndicator];
        }
        
        return;
    }
    
    [super loadUsersFromDatabase];
}

- (void)startRefreshData
{
    [self showNoSelectionUserDetails];
    
    self.showActionButton.enabled = NO;
        
    [self reloadLates:^{
        [self stopRefreshData];
    }];
    
    shouldReloadAvatars = YES;
}

#pragma mark - Notyfications

- (void)didStartRefreshPeople
{
    if (userList.count == 0)
    {
        [self addActivityIndicator];
    }
}

- (void)didEndRefreshPeople
{
    self.outOfOfficePeople = nil;
    
    [self loadUsersFromDatabase];
    [self removeActivityIndicator];
}

- (void)addActivityIndicator
{
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityIndicator startAnimating];
    
    self.activityIndicator.center = self.tableView.center;
    [self.tableView addSubview:self.activityIndicator];
    self.tableView.userInteractionEnabled = NO;
}

- (void)removeActivityIndicator
{
    self.tableView.userInteractionEnabled = YES;
    [self.activityIndicator removeFromSuperview];
}

- (void)showOutViewButton
{
    [self performBlockOnMainThread:^{
        switch (currentListState)
        {
            case ListStateAbsent:
                self.title = NSLocalizedString(@"Holiday", nil);
                break;
            case ListStateWorkFromHome:
                self.title = NSLocalizedString(@"Work from Home", nil);
                break;
            case ListStateOutOfOffice:
                self.title = NSLocalizedString(@"Out of Office", nil);
                break;
            default:break;
        }
    } afterDelay:0];
}

- (ListState)nextListState
{
    switch (currentListState)
    {
        case ListStateNotSet:
            return ListStateAbsent;
            
        case ListStateAbsent:
            return ListStateWorkFromHome;
            
        case ListStateWorkFromHome:
            return ListStateOutOfOffice;
            
        case ListStateOutOfOffice:
            return ListStateAbsent;

        default:break;
    }
    
    return ListStateAbsent;
}

- (IBAction)setListState:(id)sender {
    [self performBlockOnMainThread:^{
        UIButton *tappedButton = (UIButton *)sender;
        if([tappedButton isEqual:self.workFromHomeButton]) currentListState = ListStateWorkFromHome;
        else if([tappedButton isEqual:self.outOfOfficeButton]) currentListState = ListStateOutOfOffice;
        else currentListState = ListStateAbsent;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
    } afterDelay:0];
    
    [self showOutViewButton];
}

@end

