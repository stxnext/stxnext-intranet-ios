//
//  TabIconTableViewCell.m
//  Intranet
//
//  Created by Tomasz Walenciak on 04.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "TabIconTableViewCell.h"

#import "Branding.h"

#import "UIImage+Color.h"

@implementation TabIconTableViewCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    UIColor *bcgColor = highlighted ? [Branding stxGreen] : [Branding stxDarkGreen];
    self.contentView.backgroundColor = bcgColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    UIColor *bcgColor = selected ? [Branding stxDarkGreen] : [Branding stxDarkGreen];
    self.contentView.backgroundColor = bcgColor;
    
    UIColor *iconColor = selected ? [UIColor whiteColor] : [Branding stxLightGreen];
    UIImage *img = self.tabImageView.image;
    self.tabImageView.image = [[img imagePaintedWithColor:iconColor] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
}

- (void)secondaryLabelSetup:(NSString *)labelText
{
    
}

- (UIEdgeInsets)layoutMargins
{
    return UIEdgeInsetsZero;
}

@end
