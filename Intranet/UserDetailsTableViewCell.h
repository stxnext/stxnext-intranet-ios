//
//  UserDetailsTableViewCell.h
//  Intranet
//
//  Created by Paweł Urbanowicz on 02.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *header;
@property (weak, nonatomic) IBOutlet UILabel *details;

@end
