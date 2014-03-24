//
//  LoaderView.m
//  Intranet
//
//  Created by Adam on 24.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "LoaderView.h"

@implementation LoaderView

+ (instancetype)singleton
{
    static LoaderView *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[LoaderView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        sharedInstance.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"STXNext"]];
        imageView.center = sharedInstance.center;
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator startAnimating];
        
        activityIndicator.center = CGPointMake(imageView.center.x, imageView.center.y + imageView.frame.size.height/2 + activityIndicator.frame.size.height/2 + 10);
        
        [sharedInstance addSubview:activityIndicator];
        [sharedInstance addSubview:imageView];
    });
    
    return sharedInstance;
}

+ (void)show
{
    __block UIView *loaderView = [LoaderView singleton];
    loaderView.alpha = 0;
    
    loaderView.frame = [[UIScreen mainScreen] bounds];
    
    [APP_DELEGATE.window addSubview:loaderView];
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{

        loaderView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)showWithRefreshControl:(UIRefreshControl *)refreshControll tableView:(UITableView *)tableView
{
    tableView.hidden = YES;
    [refreshControll endRefreshing];
    
    __block UIView *loaderView = [LoaderView singleton];
    loaderView.alpha = 0;
    
    loaderView.frame = [[UIScreen mainScreen] bounds];
    
    [APP_DELEGATE.window addSubview:loaderView];
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        loaderView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)showInView:(UIView *)view
{
    __block UIView *loaderView = [LoaderView singleton];
    loaderView.alpha = 0;
    loaderView.frame = [view bounds];

    [loaderView performBlockOnAllSubviews:^(UIView *subView) {
        subView.center = view.center;
    }];
    
    [view addSubview:loaderView];
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        loaderView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)hide
{
    __block UIView *view = [LoaderView singleton];
    view.alpha = 1;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        view.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [view removeFromSuperview];
    }];
}

+ (void)hideWithRefreshControl:(UIRefreshControl *)refreshControll tableView:(UITableView *)tableView
{
    [refreshControll endRefreshing];
    __block UIView *view = [LoaderView singleton];
    view.alpha = 1;
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        view.alpha = 0;
        tableView.hidden = NO;
        
    } completion:^(BOOL finished) {

        [view removeFromSuperview];
        
    }];
}

@end
