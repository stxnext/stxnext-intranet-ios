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
#import "UIViewController+QuickObservers.h"

@implementation PGPlayerListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _recentlyRefreshedUsers = [NSMutableArray array];
    
    [self reloadTableSections];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak typeof(_recentlyRefreshedUsers) weakRecentlyRefreshedUsers = _recentlyRefreshedUsers;
    __weak typeof(self) weakSelf = self;
    
    [self addQuickObserverForNotificationWithKey:kGameManagerNotificationSessionPeopleDidChange
                                       withBlock:^(NSNotification *note) {
                                           NSArray* users = note.object;
                                           [weakRecentlyRefreshedUsers addObjectsFromArray:users];
                                           
                                           [weakSelf reloadTableSections];
                                       }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeQuickObservers];
}

#pragma mark - Table source dynamic accessors

- (void)reloadTableSections
{
    [[Users singleton] usersWithStart:nil end:nil success:^(NSArray *users) {
        NSArray* sessionPeople = [GameManager defaultManager].activeSession.people;
        
        NSComparator activityComparator = ^NSComparisonResult(id obj1, id obj2) {
            RMUser* externalUser1 = obj1;
            RMUser* externalUser2 = obj2;
            
            GMUser* user1 = [[GameManager defaultManager].activeSession personFromExternalUser:externalUser1];
            GMUser* user2 = [[GameManager defaultManager].activeSession personFromExternalUser:externalUser2];
            
            return [@(user1.active) compare:@(user2.active)];
        };
        
        NSArray* localPeople = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id IN %@", [sessionPeople valueForKey:@"externalId"]]];
        localPeople = [localPeople sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO comparator:activityComparator],
                                                                  [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        
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
    
    // Fade if user activity changed recently
    [cell.layer removeAllAnimations];
    cell.backgroundColor = [UIColor clearColor];
    
    if ([_recentlyRefreshedUsers containsObject:sessionUser])
    {
        [_recentlyRefreshedUsers removeObject:sessionUser];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            cell.backgroundColor = cell.markerView.backgroundColor;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                cell.backgroundColor = [UIColor clearColor];
            } completion:nil];
        }];
    }
    
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
    
    // Trapezoid
    CGRect rect = self.markerView.bounds;
    
    NSArray* points = @[ [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))],
                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect) - CGRectGetWidth(rect))],
                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect))],
                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + CGRectGetWidth(rect))],
                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))] ];
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPoint firstPoint = ((NSValue*)points.firstObject).CGPointValue;
    CGPathMoveToPoint(path, NULL, firstPoint.x, firstPoint.y);
    
    for (int i = 1; i < points.count; i++)
    {
        CGPoint point = ((NSValue*)points[i]).CGPointValue;
        CGPathAddLineToPoint(path, NULL, point.x, point.y);
    }
    
    CAShapeLayer* layer = [CAShapeLayer new];
    layer.frame = self.markerView.bounds;
    layer.path = path;
    layer.fillRule = kCAFillRuleNonZero;
    layer.fillColor = [UIColor blackColor].CGColor;
    
    self.markerView.layer.mask = layer;
    
    CGPathRelease(path);
}

- (void)setIsActive:(BOOL)isActive
{
    _isActive = isActive;
    
    self.markerView.backgroundColor = isActive ? [UIColor colorWithRed:0.5 green:1.0 blue:0.5 alpha:0.7] : [UIColor colorWithRed:1.0 green:0.5 blue:0.5 alpha:0.7];
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