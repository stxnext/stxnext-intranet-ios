//
//  CardsTypeTableViewController.m
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "CardsTypeTableViewController.h"

@interface CardsTypeTableViewController ()

@property (nonatomic, strong) NSIndexPath *selectedCellIndexPath;

@end

@implementation CardsTypeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectedCellIndexPath = [self indexPathForCardValuesTitle:self.selectedCardsValuesTitle];
    
    [self.tableView hideEmptySeparators];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(cardsTypeTableViewController:didFinishWithValues:cardsValuesTitle:)])
    {
        [self.delegate cardsTypeTableViewController:self
                                didFinishWithValues:[self cardValuesArrayForIndexPath:self.selectedCellIndexPath]
                                   cardsValuesTitle:[self cardValuesTitleForIndexPath:self.selectedCellIndexPath]];
    }
    
    [super viewWillDisappear:animated];
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
    
    
    if (self.selectedCellIndexPath.row == indexPath.row && self.selectedCellIndexPath.section == indexPath.section)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = [self cardValuesTitleForIndexPath:indexPath];
    cell.detailTextLabel.text = [self cardValuesStringForIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCellIndexPath = indexPath;
    
    switch (indexPath.section)
    {
        case 0:
        {
            self.selectedCellIndexPath = indexPath;
            
            switch (indexPath.row)
            {
                case 0:
                {
                    
                    
                }
                    break;
                    
                case 1:
                {
                    
                    
                }
                    break;
                    
                case 2:
                {
                    
                    
                }
                    break;
                    
                case 3:
                {
                    
                    
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
                    TextInputViewController *textInputVC = [[TextInputViewController alloc] initWithNibName:@"TextInputViewController" bundle:nil];
                    
                    textInputVC.title = @"Custom";
                    textInputVC.delegate = self;
                    textInputVC.inputText = self.customCardValues;
                    
                    [self.navigationController pushViewController:textInputVC animated:YES];
                }
                    break;
            }
        }
            break;
    }
    
    [self.tableView reloadDataAnimated:YES];
}

#pragma mark - Helpers

- (NSString *)cardValuesTitleForIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                    return FibonaciTitle;
                    
                case 1:
                    return BinaryTitle;
                    
                case 2:
                    return LargeTitle;
                    
                case 3:
                    return OneToTenTitle;
            }
        }
            break;
            
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                    return CustomTitle;
            }
        }
            break;
    }
    
    return @"";
}

- (NSIndexPath *)indexPathForCardValuesTitle:(NSString *)cardValue
{
    if ([cardValue isEqualToString:FibonaciTitle])
    {
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    if ([cardValue isEqualToString:BinaryTitle])
    {
        return [NSIndexPath indexPathForRow:1 inSection:0];
    }
    
    if ([cardValue isEqualToString:LargeTitle])
    {
        return [NSIndexPath indexPathForRow:2 inSection:0];
    }
    
    if ([cardValue isEqualToString:OneToTenTitle])
    {
        return [NSIndexPath indexPathForRow:3 inSection:0];
    }
    
    if ([cardValue isEqualToString:CustomTitle])
    {
        return [NSIndexPath indexPathForRow:0 inSection:1];
    }
    
    return [NSIndexPath indexPathForRow:0 inSection:0];
}

- (NSString *)cardValuesStringForIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                    return FibonaciValues;
                    
                case 1:
                    return BinaryValues;
                    
                case 2:
                    return LargeValues;
                    
                case 3:
                    return OneToTenValues;
            }
        }
            break;
            
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                    return self.customCardValues;
            }
        }
            break;
    }
    
    return @"";
}

- (NSArray *)cardValuesArrayForIndexPath:(NSIndexPath *)indexPath
{
    return [[self cardValuesStringForIndexPath:indexPath] componentsSeparatedByString:@", "];
}

- (NSString *)customCardValues
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"customCardValues"];
}

- (void)setCustomCardValues:(NSString *)values
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:values forKey:@"customCardValues"];
    [userDefaults synchronize];
}

#pragma mark - TextInputViewControllerDelegate

- (void)textInputViewController:(TextInputViewController *)textInputViewController didFinishWithResult:(NSString *)result
{
    NSMutableString *cardValues = [NSMutableString stringWithString:[result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    NSRegularExpression *regex;
    
    
    
    // usuwamy poczatkowe przecinki...
    regex = [NSRegularExpression regularExpressionWithPattern:@"^[ ]*,[ ]*"
                                                      options:0
                                                        error:nil];
    
    while ([regex replaceMatchesInString:cardValues
                                 options:0
                                   range:NSMakeRange(0, [cardValues length])
                            withTemplate:@""]);
    
    // ...i koncowe przecinki
    regex = [NSRegularExpression regularExpressionWithPattern:@"[ ]*,[ ]*$"
                                                      options:0
                                                        error:nil];
    
    while ([regex replaceMatchesInString:cardValues
                                 options:0
                                   range:NSMakeRange(0, [cardValues length])
                            withTemplate:@""]);
    
    // usuwamy puste karty
    regex = [NSRegularExpression regularExpressionWithPattern:@"[ ]*[,]+[ ]*[,]+[ ]*"
                                                      options:0
                                                        error:nil];
    
    while ([regex replaceMatchesInString:cardValues
                                 options:0
                                   range:NSMakeRange(0, [cardValues length])
                            withTemplate:@","] > 0);
    
    
    
    
    // kosmetyka
    regex = [NSRegularExpression regularExpressionWithPattern:@"[ ]+,[ ]+"
                                                      options:0
                                                        error:nil];
    
    [regex replaceMatchesInString:cardValues
                          options:0
                            range:NSMakeRange(0, [cardValues length])
                     withTemplate:@","];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@","
                                                      options:0
                                                        error:nil];
    
    [regex replaceMatchesInString:cardValues
                          options:0
                            range:NSMakeRange(0, [cardValues length])
                     withTemplate:@", "];
    
    // usuwamy podwójne spacje
    regex = [NSRegularExpression regularExpressionWithPattern:@"[ ]+"
                                                      options:0
                                                        error:nil];
    
    [regex replaceMatchesInString:cardValues
                          options:0
                            range:NSMakeRange(0, [cardValues length])
                     withTemplate:@" "];
    
    
    
    self.customCardValues = cardValues;
    
    [self.tableView reloadDataAnimated:YES];
}

@end
