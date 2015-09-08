//
//  BottomTiltedButton.m
//  Intranet
//
//  Created by Tomasz Walenciak on 08.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "BottomTiltedButton.h"

#import "Branding.h"

@interface BottomTiltedButton ()

@property (nonatomic, strong) UIView *underlineView;

@end

@implementation BottomTiltedButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    [self addChildView];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [self addChildView];
    
    return self;
}

- (void)addChildView
{
    _underlineView = [[UIView alloc]initWithFrame:CGRectZero];
    _underlineView.backgroundColor = self.underlineColor;
    _underlineView.hidden = YES;

    [self addSubview:_underlineView];
}

- (void)setIsTilted:(BOOL)isTilted
{
    _underlineView.hidden = !isTilted;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    
    CGFloat heightUnderline = 3.f;
    
    CGRect underlineFrame = CGRectMake(0,
                                       size.height - heightUnderline,
                                       size.width,
                                       heightUnderline);
    _underlineView.frame = underlineFrame;
}

- (UIColor *)underlineColor
{
    return [Branding stxLightGreen];
}

@end
