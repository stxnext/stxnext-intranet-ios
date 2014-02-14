//
//  FilterViewController.m
//  Intranet
//
//  Created by Adam on 30.01.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [self.tableView hideEmptySeparators];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    if ([[filterSelections[0] firstObject] isEqualToString:@"Pracownicy"])
    {
        return [self.filterStructure count];
    }
    else
    {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"Show";
            
        case 1:
            return @"Presences";

        case 2:
            return @"Localization";
            
        case 3:
            return @"Roles";
            
        case 4:
            return @"Groups";
    }
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.filterStructure[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"CellId";

    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    NSString *text = self.filterStructure[indexPath.section][indexPath.row];
    cell.textLabel.text = text;
    
    if ([filterSelections[indexPath.section] containsObject:text])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *selectedText = cell.textLabel.text;
    
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        filterSelections = [NSMutableArray arrayWithArray:@[
                                                            [NSMutableArray arrayWithArray:@[@"Pracownicy"]],
                                                            [NSMutableArray arrayWithArray:@[@"Wszyscy"]],
                                                            [[NSMutableArray alloc] init],
                                                            [[NSMutableArray alloc] init],
                                                            [[NSMutableArray alloc] init]
                                                            ]];
    }
    else if (indexPath.section == 0 || indexPath.section == 1)
    {
        filterSelections[indexPath.section] = @[selectedText];
    }
    else
    {
        if ([filterSelections[indexPath.section] containsObject:selectedText])
        {
            [filterSelections[indexPath.section] removeObject:selectedText];
        }
        else
        {
            [filterSelections[indexPath.section] addObject:selectedText];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.tableView reloadDataAnimated:YES];
    
}

- (IBAction)saveAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changeFilterSelections:)])
    {
        [self.delegate changeFilterSelections:filterSelections];
    }
    
    if (INTERFACE_IS_PHONE)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(closePopover)])
        {
            [self.delegate closePopover];
        }
    }
}

- (IBAction)cancelAction:(id)sender
{
    if (INTERFACE_IS_PHONE)
    {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(closePopover)])
        {
            [self.delegate closePopover];
        }
    }

}

- (void)setFilterSelection:(NSArray *)filterSelection
{
    filterSelections = [[NSMutableArray alloc] init];
    
    for (id obj in filterSelection)
    {
        [filterSelections addObject:[NSMutableArray arrayWithArray:obj]];
    }
}

@end
