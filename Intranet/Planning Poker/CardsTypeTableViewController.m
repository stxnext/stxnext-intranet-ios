//
//  CardsTypeTableViewController.m
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "CardsTypeTableViewController.h"

@interface CardsTypeTableViewController ()

@end

@implementation CardsTypeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView hideEmptySeparators];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 4;

        case 1:
            return 1;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    cell.textLabel.text = @"Fibonaci";
                    cell.detailTextLabel.text = @"0, 1, 2, 3, 5, 8, 13, 20, 40, 100, ?, cafe";
                }
                    break;
                    
                case 1:
                {
                    cell.textLabel.text = @"Binary";
                    cell.detailTextLabel.text = @"0, 1, 2, 4, 8, 16, 32, 64, 128, ?, cafe";
                }
                    break;
                    
                case 2:
                {
                    cell.textLabel.text = @"Large";
                    cell.detailTextLabel.text = @"0, 10, 20, 30, 50, 80, 130, 200, 400, 999, ?, cafe";
                }
                    break;
                    
                case 3:
                {
                    cell.textLabel.text = @"1 to 10";
                    cell.detailTextLabel.text = @"1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ?, cafe";
                }
                    break;
            }
        }
            break;
            
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    cell.textLabel.text = @"Custom";
                    cell.detailTextLabel.text = @"";
                }
                    break;
                    
            }
        }
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
