//
//  WidgetView.m
//  CompositeXibPart1
//
//  Created by Paul on 8/22/13.
//  Copyright (c) 2013 Paul Solt. All rights reserved.
//

#import "CardView.h"

@implementation CardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
 
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
 
    if(self)
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    [[NSBundle mainBundle] loadNibNamed:@"CardView" owner:self options:nil];
    [self addSubview:self.view];
}


- (void)setCardNumbersValue:(NSString *)value
{
    for (UILabel *l in self.cardNumbersCollection)
    {
        l.text = value;
        [l sizeToFit];
    }
}

@end
