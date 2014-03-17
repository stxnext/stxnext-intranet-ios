//
//  TextInputViewController.m
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "TextInputViewController.h"

@interface TextInputViewController ()

@end

@implementation TextInputViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.inputTextView.text = self.inputText ? : @"";
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if ([self.delegate respondsToSelector:@selector(textInputViewController:didFinishWithResult:)])
    {
        [self.delegate textInputViewController:self
                           didFinishWithResult:[self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.inputTextView becomeFirstResponder];
}

@end
