//
//  UIView+SKBounceAnimation.m
//  Intranet
//
//  Created by Dawid Żakowski on 11/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "UIView+SKBounceAnimation.h"

@implementation UIView (SKBounceAnimation)

- (void)setFrame:(CGRect)frame withAnimationDecorator:(void (^)(SKBounceAnimation* baseAnimation))animationDecorator withCompletionHandler:(dispatch_block_t)completionBlock
{
    __block NSInteger operationCount = 2;
    
    dispatch_block_t animationFinishedBlock = ^{
        if (--operationCount == 0 && completionBlock)
            completionBlock();
    };
    
    SKBounceAnimation* boundsAnimation = [SKBounceAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.fromValue = [NSValue valueWithCGRect:self.bounds];
	boundsAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    boundsAnimation.delegate = [[UIViewInternalAnimationDelegate alloc] initWithView:self withKey:@"boundsAnimation" withCompletionHandler:animationFinishedBlock];
    
    SKBounceAnimation* positionAnimation = [SKBounceAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithCGPoint:self.center];
	positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))];
    positionAnimation.delegate = [[UIViewInternalAnimationDelegate alloc] initWithView:self withKey:@"positionAnimation" withCompletionHandler:animationFinishedBlock];
    
	boundsAnimation.removedOnCompletion = positionAnimation.removedOnCompletion = NO;
	boundsAnimation.fillMode = positionAnimation.fillMode = kCAFillModeForwards;
    
    if (animationDecorator)
    {
        animationDecorator(boundsAnimation);
        animationDecorator(positionAnimation);
    }
    
	[self.layer addAnimation:boundsAnimation forKey:((UIViewInternalAnimationDelegate*)boundsAnimation.delegate).key];
	[self.layer addAnimation:positionAnimation forKey:((UIViewInternalAnimationDelegate*)positionAnimation.delegate).key];
}

@end

@implementation UIViewInternalAnimationDelegate

- (id)initWithView:(UIView *)view withKey:(NSString*)key withCompletionHandler:(dispatch_block_t)completionBlock
{
    self = [super init];
    
    if (self)
    {
        _view = view;
        _key = key;
        _animationDidFinish = completionBlock;
    }
    
    return self;
}

- (void)animationDidStop:(SKBounceAnimation *)animation finished:(BOOL)flag
{
    [_view.layer removeAnimationForKey:_key];
	[_view.layer setValue:animation.toValue forKeyPath:animation.keyPath];
    
    if (_animationDidFinish)
        _animationDidFinish();
}

@end