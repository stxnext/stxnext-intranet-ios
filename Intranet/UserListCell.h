//
//  UserListCell.h
//  Intranet
//
//  Created by Adam on 30.10.2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockView.h"

@interface UserListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userReason;
@property (weak, nonatomic) IBOutlet UILabel *userRole;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *warningDateLabel;
@property (weak, nonatomic) IBOutlet ClockView *clockView;

@end
