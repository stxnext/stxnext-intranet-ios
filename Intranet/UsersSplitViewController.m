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
    self.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (BOOL)splitViewController:(UISplitViewController *)splitViewController
//collapseSecondaryViewController:(UIViewController *)secondaryViewController
//  ontoPrimaryViewController:(UIViewController *)primaryViewController {
//    
////    if ([secondaryViewController isKindOfClass:[UINavigationController class]]
////        && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[PriceDetailTableView class]]
////        
////        //&& ([(PriceDetailTableView *)[(UINavigationController *)secondaryViewController topViewController] detailItem] == nil)
////        
////        ) {
////        
////        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
////        return YES;
////        
////    } else {
////        
////        return NO;
////        
//
//    //    }
//    return NO;
//}
@end
