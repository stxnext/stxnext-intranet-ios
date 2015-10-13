//
//  UIUnderlinedButton.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 08.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "UIUnderlinedButton.h"
#define UNDERLINE_HEIGHT 2.0f

@implementation UIUnderlinedButton

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if(self.isUnderlined)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [Branding stxLightGreen].CGColor);
        CGContextFillRect(context, CGRectMake(0.0f, self.frame.size.height - UNDERLINE_HEIGHT, self.frame.size.width, UNDERLINE_HEIGHT));
    }
}

@end