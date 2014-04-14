//
//  WidgetView.m
//  CompositeXibPart1
//
//  Created by Paul on 8/22/13.
//  Copyright (c) 2013 Paul Solt. All rights reserved.
//

#import "CardView.h"

#define kCGGradientDrawsBeyondRange (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation)

@implementation CardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
 
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
 
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    [[NSBundle mainBundle] loadNibNamed:@"CardView" owner:self options:nil];
    [self addSubview:self.view];
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowRadius = 15.0;
    
    _mainContainerView.layer.cornerRadius = 10.0;
    _mainContainerView.layer.borderWidth = 10.0;
    _mainContainerView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    _backgroundContainerView.layer.cornerRadius = 6.0;
    
    CGSize size = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height * 2);
    _backgroundView.image = [[self class] dimForSize:size];
    
    _largeValueLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _largeValueLabel.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    _largeValueLabel.layer.shadowOpacity = 0.3;
    _largeValueLabel.layer.shadowRadius = 1.5;
    
    _smallBottomValueLabel.transform = CGAffineTransformMakeRotation(M_PI);
    
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;
}

- (void)setCardNumbersValue:(NSString *)value
{
    for (UILabel *l in self.cardNumbersCollection)
        l.text = value;
}

#pragma mark Dim
+ (CGPoint)centerOfRectangle:(CGSize)rectangle
{
    return CGPointMake(rectangle.width / 2.0, rectangle.width / 2.0);
}

+ (CGSize)largestSquareFittingRectangle:(CGSize)rectangle
{
    CGFloat shortEdge = rectangle.width > rectangle.height ? rectangle.height : rectangle.width;
    return  CGSizeMake(shortEdge, shortEdge);
}

+ (CGSize)smallestSquareContainingRectangle:(CGSize)rectangle
{
    CGFloat longEdge = rectangle.width < rectangle.height ? rectangle.height : rectangle.width;
    return  CGSizeMake(longEdge, longEdge);
}

+ (UIImage*)dimForSize:(CGSize)size
{
    CGSize smallSquare = [self largestSquareFittingRectangle:size];
    CGSize largeSquare = [self smallestSquareContainingRectangle:size];
    
    CGFloat colors[] =
    {
        //  R    G    B    A
        0.0, 0.0, 0.0, 0.2,
        0.0, 0.0, 0.0, 0.8,
        0.0, 0.0, 0.0, 0.8,
    };
    
    CGFloat locations[] =
    {
        //  [0, 1]
        0.0,
        0.5,
        1.0,
    };
    
    UIGraphicsBeginImageContextWithOptions(largeSquare, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, locations, kCGGradientDrawsBeyondRange);
    CGPoint center = [self centerOfRectangle:largeSquare];
    
    CGContextDrawRadialGradient(context, gradient, center, 0.0, center, smallSquare.width + 5.0 /* 5.0 is a fix for iPhone 5 unshaded corners */, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);
    CGContextRestoreGState(context);
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
