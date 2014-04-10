//
//  PGSessionGameplayViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 02/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGSessionGameplayViewController.h"

@implementation PGSessionGameplayViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GameManager defaultManager] joinActiveSessionWithCompletionHandler:^(GameManager *manager, NSError *error) {
        if (error)
            return;
        
        self.navigationItem.prompt = manager.listener.localAddress;
        
        [manager fetchActiveSessionUsersWithCompletionHandler:^(GameManager *manager, NSError *error) {
            if (error)
            {
                [manager leaveActiveSession];
                
                [UIAlertView showWithTitle:@"Server problem" message:@"Could not load poker session from game server." handler:nil];
                return;
            }
            
            // Done here
        }];
    } withDisconnectHandler:^(GameManager *manager, NSError *error) {
        if (![self isMovingFromParentViewController])
            [self.navigationController popViewControllerAnimated:YES];
        
        if (error)
        {
            [UIAlertView showWithTitle:@"Server problem" message:@"Connection to server was lost. Please try again." handler:nil];
            return;
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[GameManager defaultManager] leaveActiveSession];
}

#pragma mark - User action

- (void)userDidChooseCard:(GMCard*)card
{
    [[GameManager defaultManager] voteWithCard:card inCurrentTicketWithCompletionHandler:^(GameManager *manager, NSError *error) {
        // TODO
    }];
}

#pragma mark - Carousel

#define UnSelectedRadius 700
#define SelectedRadius 1000
#define ScaleFactor 1.25
#define MENUSIZE 44

- (void)setUp
{
    radius = UnSelectedRadius;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self setUp];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _carousel.type = iCarouselTypeInvertedCylinder;
    _carousel.decelerationRate = 0.8;
    
    selectedIndex = -1;
}

- (NSArray*)cards
{
    return [GameManager defaultManager].activeSession.deck.cards;
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.cards.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (view == nil)
    {
        view = [[CardView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 293)];
        
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnItemWithGesture:)];
        
        gesture.delegate = self;
        
        [((CardView *)view).view addGestureRecognizer:gesture];
    }
    
    GMCard* card = self.cards[index];
    [((CardView *)view) setCardNumbersValue:card.displayValue];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return YES;
        }
            
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                return 0.0f;
            }
            
            return value;
        }
            
        case iCarouselOptionArc:
        {
            return 3.44;
        }
            
        case iCarouselOptionRadius:
        {
            return radius;
        }
            
        case iCarouselOptionSpacing:
        {
            return 1;
        }
            
        default:
        {
            return value;
        }
    }
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    if (carousel.viewpointOffset.height > 0)
    {
        if (index == selectedIndex)
        {
            //[self flipCard];
            [self moveCardDown];
        }
        else
        {
            [self moveCardDown];
            selectedIndex = index;
            
            [self performBlockOnMainThread:^{
                
                [self moveCardUp];
                
            } afterDelay:0.4];
        }
    }
    else
    {
        selectedIndex = index;
        [self moveCardUp];
    }
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel
{
    if (carousel.viewpointOffset.height > 0)
    {
        [self moveCardDown];
    }
}

- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index
{
    return !(carousel.isDecelerating || carousel.isDragging || carousel.isScrolling || isAnimating);
}

- (void)scaleView:(UIView *)view withFactor:(CGFloat)factor
{
    BOOL scaleUp = factor > 0;
    
    if (scaleUp)
    {
        view.transform = CGAffineTransformMakeScale(factor, factor);
    }
    else
    {
        view.transform = CGAffineTransformIdentity;
    }
}

- (CGRect)scaleViewFrame:(CGRect)frame withFactor:(CGFloat)factor
{
    CGRect tempFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    BOOL scaleUp = factor > 0;
    
    factor = fabs(factor);
    
    frame.size.width = scaleUp ? frame.size.width * factor : frame.size.width / factor;
    frame.size.height = scaleUp ? frame.size.height * factor : frame.size.height / factor;
    
    if (scaleUp)
    {
        frame.origin.x -= (frame.size.width - tempFrame.size.width) / 2;
        frame.origin.y -= (frame.size.height - tempFrame.size.height) / 2;
    }
    else
    {
        frame.origin.x += (tempFrame.size.width - frame.size.width) / 2;
        frame.origin.y += (tempFrame.size.height - frame.size.height) / 2;
    }
    
    return frame;
}

#pragma mark - gestures

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (void)panOnItemWithGesture:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            startPoint = [recognizer locationInView:(CardView *)[_carousel itemViewAtIndex:_carousel.currentItemIndex]];
        }
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint currPoint = [recognizer locationInView:(CardView *)[_carousel itemViewAtIndex:_carousel.currentItemIndex]];
            
            if (!isAnimating)
            {
                if (_carousel.viewpointOffset.height > 0 && (currPoint.y - startPoint.y) > 80)
                {
                    [self moveCardDown];
                    selectedIndex = _carousel.currentItemIndex;
                }
                else if (_carousel.viewpointOffset.height == 0 && (startPoint.y - currPoint.y) > 80)
                {
                    selectedIndex = _carousel.currentItemIndex;
                    [self moveCardUp];
                }
            }
        }
            break;
            
        default:
        {
            
        }
            break;
    }
}

- (void)moveCardUp
{
    __block CGFloat vShift = fabs(_carousel.center.y - self.view.center.y - 22);
    
    if (!isAnimating)
    {
        isAnimating = YES;
        _carousel.scrollEnabled = NO;
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CGSize offset = CGSizeMake(0, vShift);
            radius = SelectedRadius;
            _carousel.viewpointOffset = offset;
            
            [UIView  animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                CardView *view = (CardView *)[_carousel itemViewAtIndex:selectedIndex];
                [self scaleView:view withFactor:ScaleFactor];
                
            } completion:^(BOOL finished) {
                
            }];
        } completion:^(BOOL finished) {
            
            isAnimating = NO;
            _carousel.scrollEnabled = YES;
        }];
    }
    
    GMCard* card = self.cards[selectedIndex];
    [self userDidChooseCard:card];
}

- (void)moveCardDown
{
    if (!isAnimating)
    {
        isAnimating = YES;
        _carousel.scrollEnabled = NO;
        
        if (isCardShowed)
        {
            [self flipCard];
            isCardShowed = NO;
        }
        
        [UIView  animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CardView *view = (CardView *)[_carousel itemViewAtIndex:selectedIndex];
            [self scaleView:view withFactor:-ScaleFactor];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                CGSize offset;
                offset = CGSizeMake(0.0f, 0);
                radius = UnSelectedRadius;
                _carousel.viewpointOffset = offset;
                
            } completion:^(BOOL finished) {
                
                isAnimating = NO;
                _carousel.scrollEnabled = YES;
            }];
        }];
    }
}

- (void)flipCard
{
    CardView *view = (CardView *)[_carousel itemViewAtIndex:selectedIndex];
    
    if (isCardShowed)
    {
        [UIView transitionWithView:view duration:0.2 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            
                            [[view subviews].lastObject removeFromSuperview];
                            [_carousel layoutSubviews];
                            
                        } completion:^(BOOL finished) {
                            
                        }];
        
        isCardShowed = NO;
    }
    else
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"empty_card"]];
        imageView.frame = CGRectMake(0, 0, view.view.frame.size.width, view.view.frame.size.height);
        imageView.clipsToBounds = YES;
        
        [UIView transitionWithView:view duration:0.2 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionTransitionFlipFromRight
                        animations:^{
                            
                            [view addSubview:imageView];
                            [_carousel layoutSubviews];
                            
                        } completion:^(BOOL finished) {
                            
                        }];
        
        isCardShowed = YES;
    }
}

@end