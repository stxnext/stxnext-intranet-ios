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

@interface MainVerticalTabBarViewController ()//<UIActionSheetDelegate>

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
                         @"employee1", //
                         @"office-worker2",
                         @"businessman243",
                         @"office17",
                         @"businessman267", // 4 - lateness
                         @"wallclock", // absence
                         @"travel25", // holiday
                         @"three115",
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    self.embededTabBarController.selectedIndex = indexPath.row;
    
    if (indexPath.row == 5 || indexPath.row == 6) {
        // absence/holiday
        UINavigationController *navCtrOpq = self.embededTabBarController.viewControllers[indexPath.row];
        
        if ([navCtrOpq.viewControllers count] == 0) {
        
            UIViewController *rootViewController = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil]instantiateViewControllerWithIdentifier:@"HolidayAbsenceControllerId"];
            
            AddOOOFormTableViewController *rootHolidayContr = (AddOOOFormTableViewController *)rootViewController;
            RequestType reqType = RequestTypeOutOfOffice;
            if (indexPath.row == 6) {
                reqType = RequestTypeAbsenceHoliday;
            }
            rootHolidayContr.currentRequest = reqType;
            
            [navCtrOpq showViewController:rootViewController sender:self];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"content_embed_segue"]) {
        self.embededTabBarController = segue.destinationViewController;
    }
}

@end
