//
//  MainVerticalTabBarViewController.h
//  Intranet
//
//  Created by Tomasz Walenciak on 04.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVerticalTabBarViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *verticalBarTableView;

@property (nonatomic) UITabBarController *embededTabBarController;

@end
