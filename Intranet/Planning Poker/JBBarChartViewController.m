//
//  JBBarChartViewController.m
//  JBChartViewDemo
//
//  Created by Terry Worona on 11/5/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "JBBarChartViewController.h"

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

@interface JBBarChartViewController () <JBBarChartViewDelegate, JBBarChartViewDataSource>
{
    int currentIndex;
    NSMutableDictionary* distribution;
}

@property (nonatomic, strong) JBBarChartView *barChartView;
@property (nonatomic, strong) PGSessionInformationView *informationView;

// Buttons
- (void)chartToggleButtonPressed:(id)sender;


@end

@implementation JBBarChartViewController

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

    self.informationView = [[PGSessionInformationView alloc] initWithFrame:CGRectMake(0,
                                                                                    self.navigationController.navigationBar.frame.size.height + 20,
                                                                                    self.view.bounds.size.width,
                                                                                    100)];

    self.informationView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.informationView];

    self.barChartView = [[JBBarChartView alloc] init];
    self.barChartView.frame = CGRectMake(kJBBarChartViewControllerChartPadding,
                                         CGRectGetMaxY(self.informationView.frame),
                                         self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2),
                                         self.view.bounds.size.height - CGRectGetMaxY(self.informationView.frame) - CGRectGetMaxY(self.navigationController.navigationBar.frame) + 20);

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.barChartView setState:JBChartViewStateExpanded];
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
    int votesCount = [[self playersForIndex:index] count];
    
    if (currentIndex != index)
    {
        currentIndex = index;
        
        [self.informationView setPlayers:[self playersForIndex:index]];

        [self.tooltipView setText: [NSString stringWithFormat:@"%i votes", votesCount]];
    }

    [self setTooltipVisible:YES animated:YES atTouchPoint:touchPoint];
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
    //return [GameManager defaultManager].activeTicket.votes;
    
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
    currentIndex = -1;

    [self setTooltipVisible:NO animated:YES];
    [self.informationView setPlayers:nil];
    
    self.barChartView.mininumValue = 1;
    self.barChartView.mininumValue = 0;
    
    self.barChartView.state = JBChartViewStateCollapsed;
    
    [UIView animateWithDuration:0.1 delay:0 options:1 animations:^{
        
        [self.barChartView reloadData];
        
    } completion:^(BOOL finished) {
    self.barChartView.state = JBChartViewStateExpanded;
    }];
}

@end