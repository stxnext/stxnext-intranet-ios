//
//  UIImage+Color.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 03.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

- (UIImage *)imagePaintedWithColor:(UIColor *)color
{
    UIImage *sourceImage = (UIImage *)self;
    CGRect rect = CGRectMake(0, 0, sourceImage.size.width, sourceImage.size.height);
    
    UIGraphicsBeginImageContextWithOptions(sourceImage.size, NO, sourceImage.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [sourceImage drawInRect:rect];
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
    CGContextFillRect(context, rect);
    
    return UIGraphicsGetImageFromCurrentImageContext();
}

@end
