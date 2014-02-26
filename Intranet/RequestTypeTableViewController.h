//
//  RequestTypeTableViewController.h
//  Intranet
//
//  Created by Adam on 25.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol RequestTypeTableViewControllerDelegate;

@interface RequestTypeTableViewController : UITableViewController

@property (nonatomic, strong) id<RequestTypeTableViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger currentType;

@end

@protocol RequestTypeTableViewControllerDelegate <NSObject>

- (void)requestTypeTableViewController:(RequestTypeTableViewController *)requestTypeTableViewController didSelectTypeWith:(NSInteger)typeId type:(NSString *)type;

@end