//
//  LoginViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIModalViewController.h"
#import "CurrentUser.h"


@protocol LoginViewControllerDelegate;
@interface LoginViewController : UIModalViewController<UIWebViewDelegate>
{
    IBOutlet UIWebView* _webView;
    NSString* _code;
    BOOL _isFinished;
}

@property (nonatomic, strong) id<LoginViewControllerDelegate> delegate;

@end


@protocol LoginViewControllerDelegate <NSObject>


- (void)loginViewController:(LoginViewController *)loginViewController finishedLoginWithUserLoginType:(UserLoginType)userLoginType;

//@optional
//- (void)finishedLoginWithCode:(NSString*)code withError:(NSError*)error;

@end