//
//  UserDetailsTableViewCell.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 02.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "UserDetailsTableViewCell.h"

@implementation UserDetailsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setFrame:(CGRect)frame {
    NSUInteger inset = 20;
    frame.origin.x += inset;
    frame.size.width -= 2 * inset;
    [super setFrame:frame];
}

@end
