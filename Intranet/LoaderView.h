//
//  LoaderView.h
//  Intranet
//
//  Created by Adam on 24.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoaderView : UIView

//+ (void)show;
+ (void)showWithRefreshControl:(UIRefreshControl *)refreshControll tableView:(UITableView *)tableView;
//+ (void)showInView:(UIView *)view;

//+ (void)hide;
+ (void)hideWithRefreshControl:(UIRefreshControl *)refreshControll tableView:(UITableView *)tableView;

@end
