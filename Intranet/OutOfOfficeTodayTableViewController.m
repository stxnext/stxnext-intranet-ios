//
//  OutOfOfficeTodayTableViewController.m
//  Intranet
//
//  Created by Adam on 19.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "OutOfOfficeTodayTableViewController.h"
#import "BottomTiltedButton.h"

@interface OutOfOfficeTodayTableViewController ()

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (nonatomic, weak) IBOutlet UIView *tabButtonsContainer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabButtonWidthOne;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabButtonWidthTwo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabButtonWidthThree;

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
    
    [self clearAllTabsTintSelecting:0];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (INTERFACE_IS_PAD) {
        CGRect containerRect = self.tabButtonsContainer.bounds;
        CGFloat oneButtonWidth = containerRect.size.width / 3.f;
        
        _tabButtonWidthOne.constant = oneButtonWidth;
        _tabButtonWidthTwo.constant = oneButtonWidth;
        _tabButtonWidthThree.constant = oneButtonWidth;
    }
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
                self.navigationItem.title = NSLocalizedString(@"Holiday", nil);
                break;
            case ListStateWorkFromHome:
                self.navigationItem.title = NSLocalizedString(@"Work from Home", nil);
                break;
            case ListStateOutOfOffice:
                self.navigationItem.title = NSLocalizedString(@"Out of Office", nil);
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
        NSInteger idx;
        if([tappedButton isEqual:self.workFromHomeButton]) {
            idx = 1;
             currentListState = ListStateWorkFromHome;
        } else if([tappedButton isEqual:self.outOfOfficeButton]) {
            idx = 2;
            currentListState = ListStateOutOfOffice;
        } else {
            idx = 0;
            currentListState = ListStateAbsent;
        }
        
        [self clearAllTabsTintSelecting:idx];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
    } afterDelay:0];
    
    [self showOutViewButton];
}

- (void)clearAllTabsTintSelecting:(NSInteger)selectedIdx
{
    NSInteger counter = 0;
    for (UIView *subButton in self.tabButtonsContainer.subviews) {
        if ([subButton isKindOfClass:[BottomTiltedButton class]]) {
            BottomTiltedButton *but = (BottomTiltedButton *)subButton;
            BOOL tilted = counter == selectedIdx;
            but.isTilted = tilted;
        }
        counter++;
    }
}

@end

