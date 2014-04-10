//
//  PGPlayerListViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 04/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PGPlayerListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView* _tableView;
    NSArray* _tableRows;
    NSMutableArray* _recentlyRefreshedUsers;
}

@end

@interface PGPlayerListCell : UITableViewCell
{
    IBOutlet UIView* _photoContainer;
}

@property (nonatomic, strong) IBOutlet UIView* markerView;
@property (nonatomic, strong) IBOutlet UIImageView* photoView;
@property (nonatomic, strong) IBOutlet UILabel* nameLabel;

@property (nonatomic, assign) BOOL isActive;

@end

@interface PGPlayerListSegue : UIStoryboardSegue

@end