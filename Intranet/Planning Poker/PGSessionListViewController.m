//
//  PGSessionListViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 27/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGSessionListViewController.h"
#import "CurrentUser.h"
#import "UITableSection.h"
#import "PGSessionLobbyViewController.h"

typedef enum SessionListType {
    SessionListTypeOwned = 0,
    SessionListTypePlayed,
    SessionListTypesCount
} SessionListType;

@implementation PGSessionListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadTableSections];
    
    [self.tableView hideEmptySeparators];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchGameInfo];
}

#pragma mark - Game client

- (void)fetchGameInfoIfNeeded
{
    if (![GameManager defaultManager].isGameInfoFetched)
        [self fetchGameInfo];
}

- (void)fetchGameInfo
{
    [self updateBarButtonStateDuringRefresh:YES];
    
    [[CurrentUser singleton] userWithStart:nil end:nil success:^(RMUser *user) {
        [[GameManager defaultManager] fetchGameInfoForExternalUser:user withCompletionHandler:^(GameManager *manager, NSError *error) {
            [self updateBarButtonStateDuringRefresh:NO];
            
            if (error)
            {
                [UIAlertView showWithTitle:@"Server problem" message:@"Could not load poker sessions from game server." handler:nil];
                return;
            }
            
            [self reloadTableSections];
        }];
    } failure:^(RMUser *cachedUser, FailureErrorType error) {
        [self updateBarButtonStateDuringRefresh:NO];
        
        [UIAlertView showWithTitle:@"Server problem" message:@"Could not load current user from users server." handler:nil];
    }];
}

#pragma mark - Bar button state

- (void)updateBarButtonStateDuringRefresh:(BOOL)isRefreshing
{
    self.navigationItem.leftBarButtonItem.enabled = !isRefreshing;
    self.navigationItem.rightBarButtonItem.enabled = ([GameManager defaultManager].decks.count > 0);
}

#pragma mark - User actions

- (IBAction)refreshContent
{
    [self fetchGameInfo];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[PGSessionLobbyViewController class]])
    {
        UITableViewCell* cell = sender;
        NSIndexPath* cellPath = [self.tableView indexPathForCell:cell];
        GMSession* session = [UITableSection rowAtIndexPath:cellPath inSectionsArray:_tableSections];
        [[GameManager defaultManager] setActiveSession:session];
    }
}

#pragma mark - Table source dynamic accessors

- (void)reloadTableSections
{
    NSArray* sections = @[ [UITableSection sectionWithName:@"OWNED SESSIONS"
                                                   withTag:SessionListTypeOwned
                                                  withRows:[GameManager defaultManager].ownerSessions],
                           
                           [UITableSection sectionWithName:@"PLAYABLE SESSIONS"
                                                   withTag:SessionListTypePlayed
                                                  withRows:[GameManager defaultManager].playerSessions] ];
    
    
    _tableSections = [UITableSection sectionsWithoutEmpty:sections];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tableSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    UITableSection* tableSection = _tableSections[section];
    return tableSection.rows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    UITableSection* tableSection = _tableSections[section];
    return tableSection.name;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GMSession* session = [UITableSection rowAtIndexPath:indexPath inSectionsArray:_tableSections];
    
    static NSString *cellId = @"sessionCellIdentifier";
    
    PGSessionListCell* cell = [tableView dequeueReusableCellWithIdentifier:cellId]
    ?: [[PGSessionListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    
    cell.session = session;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableSection* section = [UITableSection sectionAtIndexPath:indexPath inSectionsArray:_tableSections];
    
    return section.tag == SessionListTypeOwned;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        GMSession* session = [UITableSection rowAtIndexPath:indexPath inSectionsArray:_tableSections];
        
        [[GameManager defaultManager] connectedClientWithCompletionHandler:^(GameClient *client, NSError *error, dispatch_block_t disconnectCallback) {
            if (error)
            {
                [UIAlertView showWithTitle:@"Server problem" message:@"Could not connect to game server." handler:nil];
                return;
            }
            
            [client deleteSession:session user:[GameManager defaultManager].user completionHandler:^(NSError *error) {
                disconnectCallback();
                
                if (error)
                {
                    [UIAlertView showWithTitle:@"Server problem" message:@"Could not delete session on game server." handler:nil];
                    return;
                }
                
                // Remove row from source
                NSMutableArray* mutableSections = _tableSections.mutableCopy;
                UITableSection* section = [UITableSection sectionAtIndexPath:indexPath inSectionsArray:mutableSections];
                [section deleteRowAtIndexPath:indexPath];
                
                // Remove section from source - if needed
                NSMutableIndexSet* deletedSections = [NSMutableIndexSet indexSet];
                
                if (section.rows.count == 0)
                {
                    [mutableSections removeObjectAtIndex:indexPath.section];
                    [deletedSections addIndex:indexPath.section];
                }
                
                // Reassign source
                _tableSections = mutableSections;
                
                // Animate changes
                [CATransaction begin];
                [tableView beginUpdates];
                
                [CATransaction setCompletionBlock:^{
                    // Reload source from server after animation ends
                    [self fetchGameInfo];
                }];
                
                // Remove row from table
                [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                // Remove section from table - if needed
                if (deletedSections.count > 0)
                    [tableView deleteSections:deletedSections withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [tableView endUpdates];
                [CATransaction commit];
            }];
        }];
    }
}

@end

@implementation PGSessionListCell

- (void)setSession:(GMSession *)session
{
    _session = session;
    
    NSInteger onlineCount = [self.session.players filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"active = YES"]].count;
    
    NSDateFormatter* dateFormater = [NSDateFormatter new];
    dateFormater.dateFormat = @"d.MM";
    NSString* date = [dateFormater stringFromDate:self.session.startTime.mapToDate];
    
    NSDateFormatter* timeFormatter = [NSDateFormatter new];
    timeFormatter.dateFormat = @"HH:mm";
    NSString* time = [timeFormatter stringFromDate:self.session.startTime.mapToDate];
    
    NSMutableParagraphStyle* centerStyle = [NSMutableParagraphStyle new];
    centerStyle.alignment = NSTextAlignmentCenter;
    
    UIColor* aquaColor = [UIColor colorWithRed:0.0 / 255.0 green:128.0 / 255.0 blue:255.0 / 255.0 alpha:255.0 / 255.0];
    UIColor* mossColor = [UIColor colorWithRed:0.0 / 255.0 green:128.0 / 255.0 blue:64.0 / 255.0 alpha:255.0 / 255.0];
    UIColor* aluminiumColor = [UIColor colorWithRed:153.0 / 255.0 green:153.0 / 255.0 blue:153.0 / 255.0 alpha:255.0 / 255.0];
    
    NSMutableAttributedString* ownerText = [NSMutableAttributedString new];
    [ownerText appendAttributedString:[[NSAttributedString alloc] initWithString:@"Owner: "
                                                                      attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                                                    NSForegroundColorAttributeName : aluminiumColor }]];
    [ownerText appendAttributedString:[[NSAttributedString alloc] initWithString:session.owner.name
                                                                      attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                                                    NSForegroundColorAttributeName : [UIColor blackColor] }]];
    
    NSMutableAttributedString* playersText = [NSMutableAttributedString new];
    [playersText appendAttributedString:[[NSAttributedString alloc] initWithString:@"Players: "
                                                                      attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                                                    NSForegroundColorAttributeName : aluminiumColor }]];
    [playersText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d invited", self.session.players.count]
                                                                      attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                                                    NSForegroundColorAttributeName : aquaColor }]];
    [playersText appendAttributedString:[[NSAttributedString alloc] initWithString:@", "
                                                                      attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                                                    NSForegroundColorAttributeName : aluminiumColor }]];
    [playersText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d online", onlineCount]
                                                                      attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:13.0],
                                                                                    NSForegroundColorAttributeName : mossColor }]];
    
    NSMutableAttributedString* dateText = [NSMutableAttributedString new];
    [dateText appendAttributedString:[[NSAttributedString alloc] initWithString:date
                                                                     attributes:@{ NSFontAttributeName : [UIFont boldSystemFontOfSize:29.0],
                                                                                   NSForegroundColorAttributeName : [UIColor blackColor],
                                                                                   NSParagraphStyleAttributeName : centerStyle }]];
    [dateText appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", time]
                                                                     attributes:@{ NSFontAttributeName : [UIFont systemFontOfSize:17.0],
                                                                                   NSForegroundColorAttributeName : aluminiumColor,
                                                                                   NSParagraphStyleAttributeName : centerStyle }]];
    
    self.sessionNameLabel.text = session.name;
    self.ownerLabel.attributedText = ownerText;
    self.playersLabel.attributedText = playersText;
    self.dateView.attributedText = dateText;
}

@end