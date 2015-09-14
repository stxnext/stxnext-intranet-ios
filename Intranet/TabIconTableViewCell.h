//
//  TabIconTableViewCell.h
//  Intranet
//
//  Created by Tomasz Walenciak on 04.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabIconTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *tabImageView;
@property (weak, nonatomic) IBOutlet UILabel *secondaryLabel;

@end
