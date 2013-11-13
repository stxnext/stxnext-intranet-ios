//
//  SettingsViewController.m
//  Intranet
//
//  Created by MK_STX on 12/11/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "SettingsViewController.h"
#import "APIRequest.h"
#import "AFHTTPRequestOperation+Redirect.h"
#import "HTTPClient.h"
#import "AppDelegate+Navigation.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Ja";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Actions

- (IBAction)logout:(id)sender
{
    [[HTTPClient sharedClient] startOperation:[APIRequest logout]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          // logout error
                                          
                                          // We expect 302
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          if ([operation redirectToLoginView])
                                          {
                                              [[HTTPClient sharedClient] deleteCookies];

                                              // delete all cookies (to remove Google login cookies)
                                              NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                                              for (NSHTTPCookie *cookie in storage.cookies)
                                              {
                                                  [storage deleteCookie:cookie];
                                              }
                                              
                                              [APP_DELEGATE goToTabAtIndex:TabIndexUserList];
                                          }
                                          else
                                          {
                                              // logout error
                                          }
                                      }];
}

@end
