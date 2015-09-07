//
//  MainVerticalTabBarViewController.m
//  Intranet
//
//  Created by Tomasz Walenciak on 04.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "MainVerticalTabBarViewController.h"

#import "TabIconTableViewCell.h"

@interface MainVerticalTabBarViewController ()

@property (nonatomic) NSArray *modelImagesData;

@property (nonatomic) UITabBarController *embededTabBarController;

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
    
    cell.imageView.image = [UIImage imageNamed:imgName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.embededTabBarController.selectedIndex = indexPath.row;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"content_embed_segue"]) {
        self.embededTabBarController = segue.destinationViewController;
    }
}

@end
