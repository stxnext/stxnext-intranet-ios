//
//  PGPlayerListViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 04/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGPlayerListViewController.h"
#import "UITableSection.h"

#import "UserListCell.h"
#import "TeamManager.h"
#import "Model.h"
#import "CurrentUser.h"
#import "APIRequest.h"
#import "UserDetailsTableViewController.h"
#import "PGSessionGameplayViewController.h"

@implementation PGPlayerListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadTableSections];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kGameManagerNotificationSessionPeopleDidChange
                                                      object:nil queue:nil usingBlock:^(NSNotification *note) {
                                                          [self reloadTableSections];
                                                      }];
}

#pragma mark - Table source dynamic accessors

- (void)reloadTableSections
{
    [[Users singleton] usersWithStart:nil end:nil success:^(NSArray *users) {
        NSArray* sessionPeople = [GameManager defaultManager].activeSession.people;
        
        NSArray* localPeople = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id IN %@", [sessionPeople valueForKey:@"externalId"]]];
        localPeople = [localPeople sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        
        _tableRows = localPeople;
        
        [_tableView reloadData];
    } failure:^(NSArray *cachedUsers, FailureErrorType error) {
        [UIAlertView showWithTitle:@"Server problem" message:@"Could not load users from users server." handler:nil];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableRows.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"playerCell";
    
    PGPlayerListCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier] ?:
    [[PGPlayerListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    RMUser* user = _tableRows[indexPath.row];
    GMUser* sessionUser = [[GameManager defaultManager].activeSession personFromExternalUser:user];
    
    cell.nameLabel.text = [[user.name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] firstObject];
    [cell.photoView setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:user.avatarURL]];
    cell.isActive = sessionUser.active;
    
    return cell;
}

@end

@implementation PGPlayerListCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.photoView.layer.cornerRadius = _photoContainer.layer.cornerRadius = MIN(self.photoView.frame.size.width, self.photoView.frame.size.height) / 2.0;
    self.photoView.layer.masksToBounds = YES;
    self.photoView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.photoView.layer.borderWidth = 0.25;
    self.photoView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.photoView.layer.shouldRasterize = YES;
    
    _photoContainer.layer.shadowOpacity = 0.8;
    _photoContainer.layer.shadowRadius = 2.0;
    _photoContainer.layer.shadowOffset = CGSizeMake(0.7, 0.7);
    _photoContainer.layer.rasterizationScale = [UIScreen mainScreen].scale;
    _photoContainer.layer.shouldRasterize = YES;
    
    self.nameLabel.layer.shadowOpacity = 1.0;
    self.nameLabel.layer.shadowRadius = 1.0;
    self.nameLabel.layer.shadowOffset = CGSizeMake(0.7, 0.7);
    self.nameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.nameLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.nameLabel.layer.shouldRasterize = YES;
}

- (void)setIsActive:(BOOL)isActive
{
    _isActive = isActive;
    
    self.markerView.backgroundColor = isActive ? [UIColor colorWithRed:0.5 green:1.0 blue:0.5 alpha:0.0] : [UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:0.6];
}

@end

@implementation PGPlayerListSegue

- (void)perform
{
    UIViewController* root = ((UIViewController*)self.sourceViewController).view.window.rootViewController;
    
    if ([root isKindOfClass:[RESideMenu class]])
    {
        RESideMenu* menu = (RESideMenu*)root;
        menu.rightMenuViewController = self.destinationViewController;
        [menu presentRightMenuViewController];
        return;
    }
    
    [((UIViewController*)self.sourceViewController).navigationController pushViewController:self.destinationViewController animated:YES];
}

@end