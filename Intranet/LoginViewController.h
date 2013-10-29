//
//  LoginViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIModalViewController.h"

@protocol LoginViewControllerDelegate <NSObject>

- (void)finishedLoginWithCode:(NSString*)code withError:(NSError*)error;

@end

@interface LoginViewController : UIModalViewController<UIWebViewDelegate>
{
    IBOutlet UIWebView* _webView;
    NSString* _code;
    BOOL _isFinished;
}

@property (nonatomic, strong) id<LoginViewControllerDelegate> delegate;

@end
