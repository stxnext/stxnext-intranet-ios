//
//  PGSessionFooterView.m
//  Intranet
//
//  Created by Adam on 08.04.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGSessionFooterView.h"

@implementation PGSessionFooterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/



- (void)setValues:(NSArray *)values
{
    [self performBlockOnAllSubviews:^(UIView *view) {
        
        if (view != self)
        {
            [view removeFromSuperview];
        }
    }];
 
    int i = 0;
    
    for (NSString *displayValue in values)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i++ * (CGRectGetWidth(self.frame) / values.count),
                                                                   0,
                                                                   CGRectGetWidth(self.frame) / values.count,
                                                                   CGRectGetHeight(self.frame))];
    
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:9];
        label.textColor = [UIColor whiteColor];
        label.text = displayValue;
        
        [self addSubview:label];
    }
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1)];
    separatorView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:separatorView];
}


@end
