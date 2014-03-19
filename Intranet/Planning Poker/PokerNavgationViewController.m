//
//  PlaningPokerNavgationViewController.m
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PokerNavgationViewController.h"

@interface PokerNavgationViewController ()

@end

@implementation PokerNavgationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.viewControllers = @[[[UIStoryboard storyboardWithName:@"PlanningPokerStoryboard" bundle:nil] instantiateInitialViewController]];
}

@end
