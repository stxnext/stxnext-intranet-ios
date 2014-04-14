//
//  UIView+SKBounceAnimation.h
//  Intranet
//
//  Created by Dawid Żakowski on 11/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SKBounceAnimation)

- (void)setFrame:(CGRect)frame withAnimationDecorator:(void (^)(SKBounceAnimation* baseAnimation))animationDecorator withCompletionHandler:(dispatch_block_t)completionBlock;

@end

@interface UIViewInternalAnimationDelegate : NSObject
{
    UIView* _view;
    dispatch_block_t _animationDidFinish;
}

@property (nonatomic, strong, readonly) NSString* key;

- (id)initWithView:(UIView *)view withKey:(NSString*)key withCompletionHandler:(dispatch_block_t)completionBlock;

@end