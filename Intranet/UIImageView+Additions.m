//
//  UIImage+Additions.m
//  Intranet
//
//  Created by Adam on 02.12.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "UIImageView+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIImageView (Additions)

- (void)makeRadius:(CGFloat)radius borderWidth:(CGFloat)borderWidth color:(UIColor *)color
{
    self.layer.cornerRadius = radius;
    self.clipsToBounds = YES;
    self.layer.borderColor = [color CGColor];
    self.layer.borderWidth = borderWidth;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.shouldRasterize = YES;
}

@end
