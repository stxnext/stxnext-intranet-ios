//
//  PGSessionGameplayViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 02/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGSessionGameplayViewController : UIViewController<iCarouselDataSource, iCarouselDelegate, UIGestureRecognizerDelegate>

@end

#pragma mark - Carousel

#import "CardView.h"

@interface PGSessionGameplayViewController ()
{
    int radius;
    NSInteger selectedIndex;
    BOOL isAnimating;
    BOOL isCardShowed;
    CGPoint startPoint;
    IBOutlet iCarousel* _carousel;
}

@end