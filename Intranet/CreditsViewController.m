//
//  CreditsViewController.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 27.11.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import "CreditsViewController.h"

@interface CreditsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *creditsTextView;
@end

@implementation CreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close)];
    [closeButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:closeButton];
    [self.navigationItem setTitle:NSLocalizedString(@"Credits & Licenses", nil)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.creditsTextView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)close {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
