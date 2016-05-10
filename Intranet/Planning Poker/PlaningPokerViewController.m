//
//  iCarouselExampleViewController.m
//  iCarouselExample
//
//  Created by Nick Lockwood on 03/04/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "PlaningPokerViewController.h"
#import "CardView.h"
#import "GPUImage.h"
//#import <LBBlurredImage/UIImageView+LBBlurredImage.h>

#define UnSelectedRadius 700
#define SelectedRadius 1000
#define ScaleFactor 1.25
#define MENUSIZE 44
@interface PlaningPokerViewController () <UIActionSheetDelegate>
{
    int radius;
    NSInteger selectedIndex;
    BOOL isAnimating;
    BOOL isCardShowed;
    CGFloat vShift;
    CGPoint startPoint;
    
    GPUImageView *_blurView;
    UIView *_backgroundView;
}

@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, strong) NSMutableArray *items;

@end


@implementation PlaningPokerViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)setUp
{
    radius = UnSelectedRadius;
	_wrap = YES;
	self.items = [NSMutableArray arrayWithArray:@[@"0",
                                                  @"½",
                                                  @"1",
                                                  @"2",
                                                  @"3",
                                                  @"5",
                                                  @"8",
                                                  @"13",
                                                  @"20",
                                                  @"40",
                                                  @"100",
                                                  @"?",
                                                  @"cafe"
                                                  ]];
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

- (void)dealloc
{
	_carousel.delegate = nil;
	_carousel.dataSource = nil;
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _carousel.type = iCarouselTypeWheel;
    _carousel.decelerationRate = 0.8;
//    _carousel.ignorePerpendicularSwipes = NO;

    if (!BLURED_BACKGROUND)
    {
        self.title = @"Planning Poker";
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                               target:self
                                                                                               action:@selector(close)];
        self.closeButton.hidden = YES;
        self.planingPokerTitleLabel.hidden = YES;
    }
    
    selectedIndex = -1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    if (BLURED_BACKGROUND)
    {
        [self showBlurBackground];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)showBlurBackground
{
//    [self.backgroundImageView setImageToBlur:self.backgroundImage blurRadius:10 completionBlock:nil];
    self.backgroundImageView.alpha = 0.75;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    self.carousel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (IBAction)close
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UIActionSheet methods

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [_items count];
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
    
    [((CardView *)view) setCardNumbersValue:self.items[index]];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            return _wrap;
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
        [self flipCard];
        selectedIndex = index;
    }
    else
    {
        selectedIndex = index;
        [self moveCardUp];
    }
}

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel
{

}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{

}

- (void)carouselDidScroll:(iCarousel *)carousel
{

}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{

}

- (void)carouselWillBeginDragging:(iCarousel *)carousel
{
    if (carousel.viewpointOffset.height > 0)
    {
        [self moveCardDown];
    }
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate
{

}

- (void)carouselWillBeginDecelerating:(iCarousel *)carousel
{

}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel
{

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
            
            if (/*abs(startPoint.x - currPoint.x) < 100 && */!isAnimating)
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
    vShift = fabs(self.carousel.center.y - self.view.center.y - (BLURED_BACKGROUND ? 0 : 22));
    
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
