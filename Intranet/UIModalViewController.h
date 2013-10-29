//
//  UIModalViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIModalViewControllerDelegate <NSObject>

- (NSString*)storyboardIdentifier;
- (NSString*)viewControllerIdentifier;

@end

@interface UIModalViewController : UIViewController<UIModalViewControllerDelegate>

- (IBAction)close;

@end
