//
//  PokerSessionsViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PokerSessionsViewController.h"
#import "CurrentUser.h"

@interface PokerSessionsViewController ()

@property (nonatomic, strong) RMUser* currentUser;
@property (nonatomic, strong) PFPerson* parsePerson;
@property (nonatomic, strong) NSArray* ownedGames;

@end

@implementation PokerSessionsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.parsePerson = nil;
        
    [[CurrentUser singleton] userWithStart:^(NSDictionary *params) {
        
    } end:^(NSDictionary *params) {
        
    } success:^(RMUser *user) {
        
        self.currentUser = user;
        
    } failure:^(NSDictionary *data) {
        
    }];
}

- (void)setCurrentUser:(RMUser *)currentUser
{
    if ([_currentUser isEqual:currentUser] || (!currentUser && !_currentUser))
        return;
    
    _currentUser = currentUser;
    [self currentUserDidChange];
}

- (void)setParsePerson:(PFPerson *)parsePerson
{
    if ([_parsePerson isEqual:parsePerson] || (!_parsePerson && !parsePerson))
        return;
    
    _parsePerson = parsePerson;
    [self parseUserDidChange];
}

- (void)setOwnedGames:(NSArray *)ownedGames
{
    if ([_ownedGames isEqualToArray:ownedGames] || (_ownedGames.count == ownedGames.count))
        return;
    
    _ownedGames = ownedGames;
    
    [self ownedGamesDidChange];
}

- (void)currentUserDidChange
{
    PFQuery* query = [PFPerson query];
    [query whereKey:@"email" equalTo:self.currentUser.email];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error)
            return;
        
        if (objects.count == 0)
        {
            __block PFPerson* person = [PFPerson object];
            person.email = self.currentUser.email;
            [person saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                    self.parsePerson = person;
            }];
            return;
        }
        
        if ([objects.firstObject isKindOfClass:[PFPerson class]])
            self.parsePerson = objects.firstObject;
    }];
}

- (void)parseUserDidChange
{
    if (!self.parsePerson)
        return;
    
    // Increment revision to update user's last active date
    [self.parsePerson incrementKey:@"revision"];
    [self.parsePerson saveInBackground];
    
    PFQuery* query = [PFGame query];
    [query whereKey:@"owner" equalTo:self.parsePerson];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error)
            return;
        
        self.ownedGames = objects;
    }];
}

- (void)ownedGamesDidChange
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ownedGames.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
