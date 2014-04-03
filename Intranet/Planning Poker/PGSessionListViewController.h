//
//  PGSessionListViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 27/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGSessionListViewController : UITableViewController
{
    NSArray* _tableSections;
}

@end

@interface PGSessionListCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* sessionNameLabel;
@property (nonatomic, strong) IBOutlet UILabel* ownerLabel;
@property (nonatomic, strong) IBOutlet UILabel* playersLabel;
@property (nonatomic, strong) IBOutlet UITextView* dateView;

@property (nonatomic, strong) GMSession* session;

@end