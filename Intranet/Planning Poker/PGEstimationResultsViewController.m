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
#import "UIView+SKBounceAnimation.h"

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

@end

@implementation PGEstimationResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self resetBarsCache];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.prompt = [NSString stringWithFormat:@"Estimated ticket: %@", [GameManager defaultManager].activeTicket.displayValue];
    
    _isEstimationFinished = NO;
    
    [self revalidateBarItems];
    [self prepareForGameSession];
    [self resetBarsCache];
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
    
    [self animateBarsInRange:NSMakeRange(0, [self numberOfBarsInBarChartView:self.barChartView]) withAnimationDelays:0.2];
    
    [[GameManager defaultManager] joinActiveSessionWithCompletionHandler:^(GameManager *manager, NSError *error) { }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeQuickObservers];
    [self dismissParticipants];
}

- (void)viewDidLayoutSubviews
{
    currentIndex = -1;
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    if (!self.informationView)
    {
        self.informationView = [PGSessionInformationView new];
        self.informationView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:self.informationView];
    }

    self.informationView.frame = CGRectMake(0,
                                            CGRectGetHeight(self.navigationController.navigationBar.frame) + CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 0,
                                            self.view.bounds.size.width,
                                            100);
    
    if (!self.chartView)
    {
        self.barChartView = [[JBBarChartView alloc] init];
        
        self.barChartView.delegate = self;
        self.barChartView.dataSource = self;
        [self.view addSubview:self.barChartView];
    }
    
    self.barChartView.frame = CGRectMake(kJBBarChartViewControllerChartPadding,
                                         CGRectGetMaxY(self.informationView.frame),
                                         self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2),
                                         self.view.bounds.size.height - CGRectGetMaxY(self.informationView.frame) - CGRectGetHeight(self.tabBarController.tabBar.frame));
    
    if (!self.barChartView.headerView)
    {
        JBChartHeaderView *headerView = [JBChartHeaderView new];
        
        headerView.separatorColor = [UIColor clearColor];
        self.barChartView.headerView = headerView;
    }
    
    self.barChartView.headerView.frame = CGRectMake(kJBBarChartViewControllerChartPadding,
                                                    0,
                                                    self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2),
                                                    kJBBarChartViewControllerChartHeaderHeight);
    
    if (!self.barChartView.footerView)
    {
        PGSessionFooterView *footerView = [PGSessionFooterView new];
        
        footerView.backgroundColor = MAIN_APP_COLOR;
        self.barChartView.footerView = footerView;
    }
    
    self.barChartView.footerView.frame = CGRectMake(kJBBarChartViewControllerChartPadding,
                                                    ceil(self.view.bounds.size.height * 0.5) - ceil(kJBBarChartViewControllerChartFooterHeight * 0.5),
                                                    self.view.bounds.size.width - (kJBBarChartViewControllerChartPadding * 2),
                                                    kJBBarChartViewControllerChartFooterHeight);

    ((PGSessionFooterView *) self.barChartView.footerView).values = [self cardTitles];

    [self reloadView];
}

#pragma mark - Bars cache

- (void)resetBarsCache
{
    _barsCache = [NSMutableDictionary dictionary];
    _renderedBarThreshold = -1;
}

- (void)animateBarsInRange:(NSRange)barsRange withAnimationDelays:(NSTimeInterval)animationDelays
{
    _renderedBarThreshold = barsRange.location;
    
    [self animateBarsToThreshold:barsRange.location + barsRange.length withAnimationDelays:animationDelays];
}

- (void)animateBarsToThreshold:(NSInteger)threshold withAnimationDelays:(NSTimeInterval)animationDelays
{
    for (; _renderedBarThreshold < threshold && [self playersForIndex:_renderedBarThreshold].count == 0; _renderedBarThreshold++);
    
    if (_renderedBarThreshold < threshold)
    {
        [self revalidateVotes];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(animationDelays * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _renderedBarThreshold++;
            [self animateBarsToThreshold:threshold withAnimationDelays:animationDelays];
        });
    }
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

                    [self revalidateVotes];
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
}

#pragma mark - JBBarChartViewDelegate

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtAtIndex:(NSUInteger)index
{
    CGFloat multiplier = (NSInteger)index <= _renderedBarThreshold ? 1.0 : 0.0;
    CGFloat height = multiplier * [[self playersForIndex:index] count];
    
    return height;
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
    PGEstimationResultsChartBar* barView = _barsCache[@(index)] = _barsCache[@(index)] ?: [PGEstimationResultsChartBar new];
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
            [self setTooltipVisible:YES animated:YES atTouchPoint:CGPointMake(self.view.frame.size.width / [self deckCards].count * (currentIndex + 0.5), 0)];
            [self.tooltipView setText: [NSString stringWithFormat:@"%i votes", players.count]];
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

@implementation PGEstimationResultsChartBar

BOOL CGRectEqualOrBothInvisible(CGRect a, CGRect b)
{
    return CGRectEqualToRect(a, b) || (a.size.width * a.size.height == 0 && b.size.width * b.size.height == 0);
}

- (void)setFrame:(CGRect)frame
{
    if (self.layer.animationKeys.count > 0 || CGRectEqualOrBothInvisible(self.frame, frame))
    {
        [super setFrame:frame];
        return;
    }
    
    _newFrame = frame;
    
    [self animateFrameChangeWithSuperview:self.superview];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    [self animateFrameChangeWithSuperview:newSuperview];
}

- (void)animateFrameChangeWithSuperview:(UIView*)superview
{
    if (!superview || CGRectEqualOrBothInvisible(self.frame, _newFrame))
        return;
    
    [self setFrame:_newFrame withAnimationDecorator:^(SKBounceAnimation *baseAnimation) {
        baseAnimation.duration = 0.5;
        baseAnimation.numberOfBounces = 4;
    } withCompletionHandler:nil];
}

@end