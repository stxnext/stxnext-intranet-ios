//
//  PGSessionGameplayViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 02/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardView.h"

@interface PGCardPickerViewController : UIViewController<iCarouselDataSource, iCarouselDelegate, UIGestureRecognizerDelegate>
{
    int radius;
    NSInteger selectedIndex;
    BOOL isAnimating;
    BOOL isCardShowed;
    CGPoint startPoint;
    IBOutlet UIView* _containerView;
    IBOutlet iCarousel* _carousel;
    IBOutlet UIImageView* _dimView;
}

- (void)userDidChooseCard:(GMCard*)card;

@end

@interface PGSessionGameplayViewController : PGCardPickerViewController

@end