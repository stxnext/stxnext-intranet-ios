//
//  RequestTypeTableViewController.m
//  Intranet
//
//  Created by Adam on 25.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "RequestTypeTableViewController.h"

@interface RequestTypeTableViewController ()

@end

@implementation RequestTypeTableViewController

- (void)viewDidLoad
{
    self.title = @"Type";
    
    [super viewDidLoad];
    
    [self.tableView hideEmptySeparators];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.currentType >= 0)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentType inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (int i = 0 ; i < [tableView numberOfRowsInSection:0]; i++)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;

    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self performBlockOnMainThread:^{
        if ([self.delegate respondsToSelector:@selector(requestTypeTableViewController:didSelectTypeWith:type:)])
        {
            [self.delegate requestTypeTableViewController:self didSelectTypeWith:indexPath.row type:cell.textLabel.text];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    } afterDelay:0.25];
}

@end
