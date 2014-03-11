//
//  ExplanationViewController.m
//  Intranet
//
//  Created by Adam on 25.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "ExplanationViewController.h"

@interface ExplanationViewController ()

@end

@implementation ExplanationViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.textView.text = self.explanation ? : @"";
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(explanationViewController:didFinishWithExplanation:)])
    {
        [self.delegate explanationViewController:self didFinishWithExplanation:self.textView.text];
    }
}

- (void)viewDidLoad
{
    self.title = @"Explanation";
    
    [super viewDidLoad];

    [self.textView becomeFirstResponder];
}

@end
