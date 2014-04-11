//
//  UIView+SKBounceAnimation.h
//  Intranet
//
//  Created by Dawid Żakowski on 11/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SKBounceAnimation)

- (void)setFrame:(CGRect)frame withAnimationDecorator:(void (^)(SKBounceAnimation* baseAnimation))animationDecorator;

@end

@interface UIViewInternalAnimationDelegate : NSObject
{
    UIView* _view;
}

- (id)initWithView:(UIView*)view;

@end