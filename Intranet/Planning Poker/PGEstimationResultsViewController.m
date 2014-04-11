//
//  PGEstimationResultsViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 08/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGEstimationResultsViewController.h"
#import "PGTicketCreateViewController.h"
#import "UIViewController+PGSessionRuntime.h"
#import "PGSessionGameplayViewController.h"


// Views
#import "JBBarChartView.h"
#import "JBChartHeaderView.h"
#import "PGSessionFooterView.h"
#import "PGSessionInformationView.h"

// Numerics
CGFloat const kJBBarChartViewControllerChartHeight = 250.0f;
CGFloat const kJBBarChartViewControllerChartPadding = 0.0f;
CGFloat const kJBBarChartViewControllerChartHeaderHeight = 40.0f;
CGFloat const kJBBarChartViewControllerChartHeaderPadding = 10.0f;
CGFloat const kJBBarChartViewControllerChartFooterHeight = 25.0f;
CGFloat const kJBBarChartViewControllerChartFooterPadding = 5.0f;
CGFloat const kJBBarChartViewControllerBarPadding = 1;
NSInteger const kJBBarChartViewControllerMaxBarHeight = 10;
NSInteger const kJBBarChartViewControllerMinBarHeight = 5;

// Strings
NSString * const kJBBarChartViewControllerNavButtonViewKey = @"view";


@interface PGEstimationResultsViewController () <JBBarChartViewDelegate, JBBarChartViewDataSource>
{
    int currentIndex;
    NSMutableDictionary* distribution;
}

@property (nonatomic, strong) JBBarChartView *barChartView;
@property (nonatomic, strong) PGSessionInformationView *informationView;

// Buttons
- (void)chartToggleButtonPressed:(id)sender;


@end



@implementation PGEstimationResultsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.prompt = [NSString stringWithFormat:@"Estimated ticket: %@", [GameManager defaultManager].activeTicket.displayValue];
    
    _isEstimationFinished = NO;
    [self revalidateBarItems];
    
    [self prepareForGameSession];
    
    [self revalidateVotes];
    
    __weak typeof(self) weakSelf = self;
    
    [self addQuickObserverForNotificationWithKey:kGameManagerNotificationEstimationRoundDidStart withBlock:^(NSNotification *note) {
        [weakSelf popToViewControllerOfClass:[PGSessionGameplayViewController class]];
    }];
    
    [self addQuickObserverForNotificationWithKey:kGameManagerNotificationTicketVoteReceived withBlock:^(NSNotification *note) {
        [weakSelf revalidateVotes];
    }];
    
    
    [self.barChartView setState:JBChartViewStateExpanded];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[GameManager defaultManager] joinActiveSessionWithCompletionHandler:^(GameManager *manager, NSError *error) { }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeQuickObservers];
}


- (void)loadView
{
    [super loadView];
    
    currentIndex = -1;
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.informationView = [[PGSessionInformationView alloc] initWithFrame:CGRectMake(0,
                                                                                      CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 30,
                                                                                      self.view.bounds.size.width,
                                                                                      100)];
    
    self.informationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.informationView];
    
    self.barChartView = [[JBBarChartView alloc] init];
    self.barChartView.frame = CGRectMake(kJBBarChartViewControllerChartPadding,
                                         CGRectGetMaxY(self.informationView.frame),
                                         self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2),
                                         self.view.bounds.size.height - CGRectGetMaxY(self.informationView.frame) - CGRectGetHeight(self.tabBarController.tabBar.frame));
    
    self.barChartView.delegate = self;
    self.barChartView.dataSource = self;
    
    JBChartHeaderView *headerView = [[JBChartHeaderView alloc] initWithFrame:CGRectMake(kJBBarChartViewControllerChartPadding,
                                                                                        0,
                                                                                        self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2),
                                                                                        kJBBarChartViewControllerChartHeaderHeight)];
    
    headerView.separatorColor = [UIColor clearColor];
    self.barChartView.headerView = headerView;
    
    PGSessionFooterView *footerView = [[PGSessionFooterView alloc] initWithFrame:CGRectMake(kJBBarChartViewControllerChartPadding,
                                                                                            ceil(self.view.bounds.size.height * 0.5) - ceil(kJBBarChartViewControllerChartFooterHeight * 0.5),
                                                                                            self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2),
                                                                                            kJBBarChartViewControllerChartFooterHeight)];
    
    footerView.values = [self cardTitles];
    footerView.backgroundColor = MAIN_APP_COLOR;
    self.barChartView.footerView = footerView;
    
    [self.view addSubview:self.barChartView];
    
    [self reloadView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadView)];
    
}

#pragma mark - Bar button

- (void)revalidateBarItems
{
    if ([GameManager defaultManager].activeSession.isOwnedByCurrentUser)
    {
        if (_isEstimationFinished)
        {
            self.navigationItem.title = @"Estimation Results";
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"New" style:UIBarButtonItemStylePlain handler:^(id sender) {
                [self popToViewControllerOfClass:[PGTicketCreateViewController class]];
            }];
        }
        else
        {
            self.navigationItem.title = @"Estimation Progress";
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithTitle:@"Stop" style:UIBarButtonItemStylePlain handler:^(id sender) {
                [[GameManager defaultManager] stopRoundWithCompletionHandler:^(GameManager *manager, NSError *error) {
                    if (error)
                        return;
                    
                    _isEstimationFinished = YES;
                    
                    [self revalidateBarItems];
                }];
            }];
        }
    }
}

#pragma mark - Votes distribution

- (void)revalidateVotes
{
    [self reloadView];
    // TODO
    NSLog(@"%@", [GameManager defaultManager].activeTicket.votesDistribution);
}

#pragma mark - JBBarChartViewDelegate

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtAtIndex:(NSUInteger)index
{
    return [[self playersForIndex:index] count];
}

#pragma mark - JBBarChartViewDataSource

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView
{
    return [[self deckCards] count];
}

- (NSUInteger)barPaddingForBarChartView:(JBBarChartView *)barChartView
{
    return kJBBarChartViewControllerBarPadding;
}

- (UIView *)barChartView:(JBBarChartView *)barChartView barViewAtIndex:(NSUInteger)index
{
    UIView *barView = [[UIView alloc] init];
    barView.backgroundColor = MAIN_APP_COLOR;
    
    return barView;
}

- (UIColor *)barSelectionColorForBarChartView:(JBBarChartView *)barChartView
{
    return [UIColor whiteColor];
}

- (void)barChartView:(JBBarChartView *)barChartView didSelectBarAtIndex:(NSUInteger)index touchPoint:(CGPoint)touchPoint
{
    if (currentIndex != index)
    {
        currentIndex = index;
        
        [self selectCurrentIndex];
    }
}

- (void)didUnselectBarChartView:(JBBarChartView *)barChartView
{
    //    [self setTooltipVisible:NO animated:YES];
}

#pragma mark - Overrides

- (JBChartView *)chartView
{
    return self.barChartView;
}

#pragma mark - data

// Returns array of GMCard objects.
// Example usage:
// NSArray* cardNames = [[self deckCards] valueForKey:@"displayValue"]; // returns array of NSString with card names
- (NSArray*)deckCards
{
    return [GameManager defaultManager].activeSession.deck.cards;
}

// Returns array of GMVote objects.
- (NSArray*)roundVotes
{
    return [GameManager defaultManager].activeTicket.votes;
    
    // Mock here
    NSMutableArray* votes = [NSMutableArray array];
    
    for (int i = 0; i < 40; i++)
    {
        GMVote* vote = [GMVote new];
        vote.card = self.deckCards[arc4random() % self.deckCards.count];
        vote.player = [GameManager defaultManager].activeSession.players[arc4random() % [GameManager defaultManager].activeSession.players.count];
        
        [votes addObject:vote];
    }
    
    return votes;
}

// Returns dictionary:
// key: GMCard object
// value: array of GMPlayer objects
- (NSDictionary *)votesDistribution
{
    return [NSDictionary dictionaryWithDictionary:[GameManager defaultManager].activeTicket.votesDistribution];
    
    if (!distribution)
    {
        distribution = [NSMutableDictionary dictionary];
        
        for (GMCard* card in self.deckCards)
            distribution[card] = [NSMutableArray array];
        
        for (GMVote* vote in self.roundVotes)
        {
            //        distribution[vote.card] = distribution[vote.card] ?: [NSMutableArray array];
            [distribution[vote.card] addObject:vote.player];
        }
    }
    
    return distribution;
}

- (NSArray *)cardTitles
{
    NSMutableArray *cards = [NSMutableArray new];
    
    for (GMCard *card in [self deckCards])
    {
        [cards addObject:card.displayValue];
    }
    
    return cards;
}

- (NSArray *)playersForIndex:(NSInteger)index
{
    GMCard *card = (GMCard *)[self deckCards][index];
    
    return [self votesDistribution][card];
}

- (void)reloadView
{
    distribution = nil;
    
    self.barChartView.mininumValue = 1;
    self.barChartView.mininumValue = 0;
    
    [self.barChartView reloadData];
    
    [self selectCurrentIndex];
}

- (void)selectCurrentIndex
{
    if (currentIndex != -1)
    {
        NSArray *players = [self playersForIndex:currentIndex];
        
        if ([players count])
        {
            [self.informationView setPlayers:players];
            self.barChartView.showsVerticalSelection = YES;
            [self.tooltipView setText: [NSString stringWithFormat:@"%i votes", players.count]];
            [self setTooltipVisible:YES animated:YES atTouchPoint:CGPointMake(self.view.frame.size.width / [self deckCards].count * (currentIndex + 0.5), 0)];
        }
        else
        {
            self.barChartView.showsVerticalSelection = NO;
            currentIndex = -1;
            [self.informationView setPlayers:nil];
            [self setTooltipVisible:NO animated:NO];
        }
    }
}

@end
