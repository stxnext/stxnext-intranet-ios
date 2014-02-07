//
//  UIView+Screenshot.m
//  Intranet
//
//  Created by Adam on 07.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "UIView+Screenshot.h"

@implementation UIView (Screenshot)

- (UIImage *)convertViewToImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
