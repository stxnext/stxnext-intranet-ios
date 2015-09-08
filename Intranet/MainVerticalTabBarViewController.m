//
//  MainVerticalTabBarViewController.m
//  Intranet
//
//  Created by Tomasz Walenciak on 04.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "MainVerticalTabBarViewController.h"

#import "TabIconTableViewCell.h"
#import "AddOOOFormTableViewController.h"

#import "UIImage+Color.h"

@interface MainVerticalTabBarViewController ()<UIActionSheetDelegate>

@property (nonatomic) NSArray *modelImagesData;
@property (nonatomic) UITabBarController *embededTabBarController;
@property (nonatomic) NSUInteger selectedRow;

@end

@implementation MainVerticalTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.verticalBarTableView.dataSource = self;
    self.verticalBarTableView.delegate = self;
    
    _modelImagesData = @[
                         @"employee1",
                         @"office-worker2",
                         @"businessman243",
                         @"office17",
                         @"three115",
                         @"wallclock",
                         ];
    
    NSIndexPath *initialSelected = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.verticalBarTableView selectRowAtIndexPath:initialSelected animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Delegate/Data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.modelImagesData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TabIconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tab_cell" forIndexPath:indexPath];
    
    NSString *imgName = _modelImagesData[indexPath.row];
    
    UIImage *imageInCell = [UIImage imageNamed:imgName];
    
    cell.tabImageView.image = [[imageInCell imagePaintedWithColor:[Branding stxLightGreen]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cell.selected = indexPath.row == _selectedRow;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 5) {
        
        UIActionSheet *popoverDelay = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Absence", nil)
                                                                 delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Absence / Holiday", @"Out of office", nil];
        CGRect rectCell = [tableView rectForRowAtIndexPath:indexPath];
        
        CGRect rect = [tableView convertRect:rectCell toView:self.view];
        
        [popoverDelay showFromRect:rect inView:self.view animated:YES];
        return [NSIndexPath indexPathForRow:_selectedRow inSection:0];
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 5) {

        
    } else {
        _selectedRow = indexPath.row;
        self.embededTabBarController.selectedIndex = indexPath.row;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"content_embed_segue"]) {
        self.embededTabBarController = segue.destinationViewController;
    }
}

#pragma mark - UIActionSheetDelegate


- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex < 2) {
        _selectedRow = 5;
        self.embededTabBarController.selectedIndex = _selectedRow;
        NSIndexPath *absencesIP = [NSIndexPath indexPathForRow:_selectedRow inSection:0];
        [self.verticalBarTableView selectRowAtIndexPath:absencesIP animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    if (buttonIndex == 1) {
        UINavigationController *navVc = self.embededTabBarController.viewControllers[5];
        
        AddOOOFormTableViewController *form = (AddOOOFormTableViewController *)[navVc.viewControllers firstObject];
        form.currentRequest = (int)buttonIndex;
    }
}

@end
