//
//  UsersSplitViewController.m
//  Intranet
//
//  Created by Tomasz Walenciak on 04.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "UsersSplitViewController.h"

@interface UsersSplitViewController ()

@end

@implementation UsersSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
//    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
