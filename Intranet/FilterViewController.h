//
//  FilterViewController.h
//  Intranet
//
//  Created by Adam on 30.01.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterViewControllerDelegate <NSObject>

- (void)changeFilterSelections:(NSArray *)filterSelection;

@end

@interface FilterViewController : UITableViewController
{
    NSMutableArray *filterSelections;
}

@property (strong, nonatomic) NSMutableArray *filterStructure;
@property (nonatomic, strong) id<FilterViewControllerDelegate> delegate;

- (void)setFilterSelection:(NSArray *)filterSelection;

@end
