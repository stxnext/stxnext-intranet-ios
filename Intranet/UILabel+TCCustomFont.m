//
//  UILabel+TCCustomFont.m
//  Intranet
//
//  Created by Adam on 03.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "UILabel+TCCustomFont.h"

@implementation UILabel (TCCustomFont)

- (NSString *)fontName
{
    return self.font.fontName;
}

- (void)setFontName:(NSString *)fontName
{
    self.font = [UIFont fontWithName:fontName size:self.font.pointSize];
}

@end
