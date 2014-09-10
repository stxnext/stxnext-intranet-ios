//
//  LoginViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "LoginViewController.h"
//#import "GooglePlusClient.h"

#define kGoogleAuthSignInURL @"https://accounts.google.com/o/oauth2/auth?scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcalendar+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcalendar.readonly&redirect_uri=https%3A%2F%2Fintranet.stxnext.pl%2Fauth%2Fcallback&response_type=code&client_id=83120712902.apps.googleusercontent.com&access_type=offline"

@implementation LoginViewController

@synthesize delegate = _delegate;

#pragma mark View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup web view
    _webView.scrollView.bounces = NO;
    _webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Clear code and state
    _code = nil;
    _isFinished = NO;
    
    // Send request
    NSURL* url = [NSURL URLWithString:kGoogleAuthSignInURL];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    
}

//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    if (INTERFACE_IS_PAD)
//    {
//        self.view.bounds = CGRectMake(0, 0, 700, 650);
//    }
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
//{
//    if (INTERFACE_IS_PAD)
//    {
//        self.view.bounds = CGRectMake(0, 0, 700, 650);
//    }
//}
//
//- (void)viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    
//    if (INTERFACE_IS_PAD)
//    {
//        self.view.bounds = CGRectMake(0, 0, 700, 650);
//    }
//}

#pragma mark Utilities

- (NSString *)fetchCodeFromUrl:(NSURL *)url
{
    // Fetch code from request URL address using regex
    NSString* urlString = url.absoluteString;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"intranet\\.stxnext\\.pl\\/auth\\/callback\\?code=(.*)" options:0 error:nil];
    NSTextCheckingResult* match = [regex firstMatchInString:urlString options:0 range:NSMakeRange(0, urlString.length)];
    NSRange range = (match.numberOfRanges == 2) ? [match rangeAtIndex:1] : NSMakeRange(NSNotFound, 0);
    NSString* code = (range.location != NSNotFound) ? [urlString substringWithRange:range] : nil;
    
    return code;
}

#pragma mark Web view

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // Break if already found a code
    if (_isFinished)
        return NO;
    
    // Fetch code from request url
    _code = [self fetchCodeFromUrl:request.URL] ?: _code;
    
    // Break if code is not found
    if (!_code)
        return YES;
    
    // Mark as finished
    _isFinished = YES;
    
    // Call delegate
    [_delegate finishedLoginWithCode:_code withError:nil];
    
    // Dismiss modal
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self close];
    });
    
    // Prevent any further calls
    return NO;
}

#pragma mark Modal delegate

+ (NSString *)storyboardIdentifier
{
    return kStoryboardNameModals;
}

+ (NSString *)viewControllerIdentifier
{
    return kStoryboardControllerNameLogin;
}

@end
