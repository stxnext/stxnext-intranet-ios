//
//  LoaderView.m
//  Intranet
//
//  Created by Adam on 24.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "LoaderView.h"

#define NavigationBarHeight 44
#define TabBarHeight 50

@implementation LoaderView
static BOOL inProgress;
static UIActivityIndicatorView *activityIndicator;

+ (instancetype)singleton
{
    static LoaderView *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        CGRect screenFrame = [[UIScreen mainScreen] bounds];
        
        sharedInstance = [[LoaderView alloc] initWithFrame:screenFrame];
        sharedInstance.backgroundColor = [UIColor clearColor];
        
        CGFloat y = [UIApplication sharedApplication].statusBarFrame.size.height + NavigationBarHeight;
        CGFloat height = screenFrame.size.height - y - TabBarHeight;
        
        UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(0, y, 320, height)];
        innerView.backgroundColor = [UIColor colorWithRed:31 / 255.0 green:31 / 255.0 blue:32 / 255.0 alpha:1];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"STXNext"]];
        imageView.center = sharedInstance.center; CGPointMake(innerView.frame.size.width / 2, innerView.frame.size.height / 2);
        
        activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = CGPointMake(imageView.center.x, imageView.center.y + imageView.frame.size.height/2 + activityIndicator.frame.size.height/2 + 15);
        [activityIndicator startAnimating];
        activityIndicator.hidden = YES;
        
        [sharedInstance addSubview:innerView];
        [sharedInstance addSubview:imageView];
        [sharedInstance addSubview:activityIndicator];
    });
    
    return sharedInstance;
}

+ (void)show
{
    [self showWithRefreshControl:nil tableView:nil];
}

+ (void)showWithRefreshControl:(UIRefreshControl *)refreshControll tableView:(UITableView *)tableView
{
    activityIndicator.hidden = YES;
    tableView.hidden = YES;
    [refreshControll endRefreshing];
    
    __block UIView *loaderView = [LoaderView singleton];
    loaderView.alpha = 0;
    loaderView.frame = [[UIScreen mainScreen] bounds];
    
    [APP_DELEGATE.window addSubview:loaderView];
    
    [UIView animateWithDuration:0.5 delay:inProgress ? 0.3 : 0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        inProgress = YES;
        loaderView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        activityIndicator.hidden = NO;
        inProgress = NO;
    }];
}

+ (void)hide
{
    [self hideWithRefreshControl:nil tableView:nil];
}

+ (void)hideWithRefreshControl:(UIRefreshControl *)refreshControll tableView:(UITableView *)tableView
{
    activityIndicator.hidden = YES;
    [refreshControll endRefreshing];
    __block UIView *view = [LoaderView singleton];
    view.alpha = 1;
    
    [UIView animateWithDuration:0.3 delay:inProgress ? 0.3 : 0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        inProgress = YES;
        view.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [view removeFromSuperview];
        tableView.hidden = NO;
        
        inProgress = NO;
    }];
}

@end
