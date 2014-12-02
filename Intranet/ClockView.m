//
//  ClockView.m
//  Intranet
//
//  Created by Adam on 13.11.2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "ClockView.h"

@implementation ClockView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.color = MAIN_APP_COLOR;
        self.hidden = YES;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
        
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //tarcza
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(context, 0.5);
    
    CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2); // get the circle centre
    CGFloat radius = center.x;
    CGFloat startAngle = -((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = ((2 * (float)M_PI) + startAngle);
    
    CGContextAddArc(context, center.x, center.y, radius - 1, startAngle, endAngle, 0);
    CGContextStrokePath(context);
    
    //srodek
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGContextSetLineWidth(context, 2);
    
    radius = 2;
    
    CGContextAddArc(context, center.x, center.y, radius - 1, startAngle, endAngle, 0);
    CGContextStrokePath(context);
    
    //wskazowki:
    
    //dluga
    CGContextSetLineWidth(context, 1.5);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddLineToPoint(context, center.x + center.x * 0.6, center.y - center.x * 0.6);
    
    CGContextStrokePath(context);
    
    //krotka
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddLineToPoint(context, center.x + center.x * 0.3, center.y + center.x * 0.45);
    
    CGContextStrokePath(context);
}

- (void)setColor:(UIColor *)color
{
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    _color = color;
    [self setNeedsDisplay];
}

@end
