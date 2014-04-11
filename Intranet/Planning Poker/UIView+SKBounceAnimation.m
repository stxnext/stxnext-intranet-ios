//
//  UIView+SKBounceAnimation.m
//  Intranet
//
//  Created by Dawid Żakowski on 11/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "UIView+SKBounceAnimation.h"

@implementation UIView (SKBounceAnimation)

- (void)setFrame:(CGRect)frame withAnimationDecorator:(void (^)(SKBounceAnimation* baseAnimation))animationDecorator
{
    SKBounceAnimation* boundsAnimation = [SKBounceAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.fromValue = [NSValue valueWithCGRect:self.bounds];
	boundsAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    SKBounceAnimation* positionAnimation = [SKBounceAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:self.center];
	positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))];
    
    boundsAnimation.delegate = positionAnimation.delegate = [[UIViewInternalAnimationDelegate alloc] initWithView:self];
	boundsAnimation.removedOnCompletion = positionAnimation.removedOnCompletion = YES;
	boundsAnimation.fillMode = positionAnimation.fillMode = kCAFillModeForwards;
    
    if (animationDecorator)
    {
        animationDecorator(boundsAnimation);
        animationDecorator(positionAnimation);
    }
    
	[self.layer addAnimation:boundsAnimation forKey:@"boundsAnimation"];
	[self.layer addAnimation:positionAnimation forKey:@"positionAnimation"];
}

@end

@implementation UIViewInternalAnimationDelegate

- (id)initWithView:(UIView*)view
{
    self = [super init];
    
    if (self)
    {
        _view = view;
    }
    
    return self;
}

- (void)animationDidStop:(SKBounceAnimation *)animation finished:(BOOL)flag
{
	[_view.layer setValue:animation.toValue forKeyPath:animation.keyPath];
}

@end