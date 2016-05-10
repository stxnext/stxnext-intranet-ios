//
//  GreenSTXButton.m
//  Intranet
//
//  Created by Tomasz Walenciak on 10.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "GreenSTXButton.h"

#import "Branding.h"

@implementation GreenSTXButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setBackgroundColor:[Branding stxGreen]];
    [self.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.f]];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

@end
