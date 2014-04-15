//
//  PGSessionGameplayViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 02/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGSessionGameplayViewController.h"
#import "UIViewController+PGSessionRuntime.h"
#import "UIImage+ImageEffects.h"
#import "RSTimingFunction.h"

@implementation PGSessionGameplayViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self prepareForGameSession];
    
    __weak typeof(self) weakSelf = self;
    
    [self addQuickObserverForNotificationWithKey:kGameManagerNotificationEstimationRoundDidStart
                                       withBlock:^(NSNotification *note) {
                                           [weakSelf revalidateActiveTicket];
                                       }];
    
    [self addQuickObserverForNotificationWithKey:kGameManagerNotificationEstimationRoundDidEnd
                                       withBlock:^(NSNotification *note) {
                                           [weakSelf performSegueWithIdentifier:@"FinishEstimationSegue" sender:nil];
                                       }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self revalidateActiveTicket];
    
    [[GameManager defaultManager] joinActiveSessionWithCompletionHandler:^(GameManager *manager, NSError *error) {
        if (error)
            return;
        
        [self revalidateActiveTicket];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeQuickObservers];
}

#pragma mark - Prompt

- (void)revalidateActiveTicket
{
    GMTicket* ticket = [GameManager defaultManager].activeTicket;
    self.navigationItem.prompt = ticket ? [NSString stringWithFormat:@"Estimated ticket: %@", ticket.displayValue] : nil;
    [self showWaitingHud:(ticket == nil) withMessage:@"Waiting for tickets..."];
}

#pragma mark - Loading alert

- (void)showWaitingHud:(BOOL)visible withMessage:(NSString*)message
{
    if (visible && !self.progressHud.isVisible)
    {
        UIGraphicsBeginImageContextWithOptions(_containerView.bounds.size, _containerView.opaque, 0.0f);
        [_containerView drawViewHierarchyInRect:_containerView.bounds afterScreenUpdates:NO];
        UIImage* snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIImage* blurredSnapshot = [snapshotImage applyBlurWithRadius:7.5 tintColor:[UIColor colorWithWhite:0.0 alpha:0.2] saturationDeltaFactor:0.5 maskImage:nil];
        _dimView.image = blurredSnapshot;
        
        [UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _dimView.alpha = 1.0;
        } completion:nil];
        
        [self.progressHud showWithStatus:message];
    }
    else if (!visible && self.progressHud.isVisible)
    {
        [UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _dimView.alpha = 0.0;
        } completion:nil];
        
        [self.progressHud dismiss];
    }
}

#pragma mark - User action

- (void)userDidChooseCard:(GMCard*)card
{
    [super userDidChooseCard:card];
    
    [[GameManager defaultManager] voteWithCard:card inCurrentTicketWithCompletionHandler:^(GameManager *manager, NSError *error) {
        
    }];
}

@end

#pragma mark - Carousel card picker

#define UnSelectedRadius 700
#define SelectedRadius (INTERFACE_IS_PHONE_SMALL_SCREEN ? 800 : 1000)
#define ScaleFactor (INTERFACE_IS_PHONE_SMALL_SCREEN ? 1.05 : 1.25)
#define YShift (INTERFACE_IS_PHONE_SMALL_SCREEN ? 4 : 12)

@implementation PGCardPickerViewController

- (void)userDidChooseCard:(GMCard*)card
{
    
}

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
    _carousel.decelerationRate = 0.8875;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self resetCardsSelection];
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
            
        case iCarouselOptionFadeMin:
        {
            return -0.25;
        }
            
        case iCarouselOptionFadeMax:
        {
            return 0.25;
        }
            
        case iCarouselOptionArc:
        {
            return 3.0;
        }
            
        case iCarouselOptionRadius:
        {
            return radius;
        }
            
        case iCarouselOptionSpacing:
        {
            return 1;
        }
        
        case iCarouselOptionTimeFunction:
        {
            static RSTimingFunction* function = nil;
            function = function ?: [RSTimingFunction timingFunctionWithName:kRSTimingFunctionEaseOut];
            return [function valueForX:value];
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
    __block CGFloat vShift = YShift;
    
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

- (void)resetCardsSelection
{
    // If card is moved up
    if (_carousel.viewpointOffset.height > 0)
    {
        CardView *view = (CardView *)[_carousel itemViewAtIndex:selectedIndex];
        
        // Unscale its view
        [self scaleView:view withFactor:-ScaleFactor];
        
        // Reset radius and viewport
        radius = UnSelectedRadius;
        _carousel.viewpointOffset = CGSizeZero;
    }
    
    // Reset state to defaults
    selectedIndex = -1;
    isAnimating = NO;
    isCardShowed = NO;
    
    // Scroll to beginning and revalidate items
    [_carousel scrollToItemAtIndex:0 animated:NO];
    [_carousel reloadData];
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