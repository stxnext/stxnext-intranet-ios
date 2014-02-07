//
//  iCarouselExampleViewController.h
//  iCarouselExample
//
//  Created by Nick Lockwood on 03/04/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"


@interface PlaningPokerViewController : UIViewController <iCarouselDataSource, iCarouselDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIImage *backgroundImage;

@property (nonatomic, strong) IBOutlet iCarousel *carousel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
