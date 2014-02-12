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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Ja";
    
    [[HTTPClient sharedClient] startOperation:[APIRequest user]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          // error
                                          
                                          // We expect 302
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSString *html = operation.responseString;
                                          NSArray *htmlArray = [html componentsSeparatedByString:@"\n"];
                                          
                                          NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"id: [0-9]+,"];
                                          NSString *userID ;
                                          
                                          for (NSString *line in htmlArray)
                                          {
                                              userID = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                                              NSLog(@"%@", userID);
                                              
                                              if ([predicate evaluateWithObject:userID])
                                              {
                                                  userID = [[userID stringByReplacingOccurrencesOfString:@"id: " withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@""];
                                                  NSLog(@"%@", userID);
                                                  break;
                                              }
                                          }
                                      }];

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
                                              NSArray *keys = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys];
                                              
                                              for (NSString* key in keys)
                                              {
                                                  // your code here
                                                  NSLog(@"value: %@ forKey: %@",[[NSUserDefaults standardUserDefaults] valueForKey:key],key);
                                              }
                                              
                                              [[HTTPClient sharedClient] deleteCookies];

                                              // delete all cookies (to remove Google login cookies)
                                              {
                                                  NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                                                  
                                                  for (NSHTTPCookie *cookie in storage.cookies)
                                                  {
                                                      NSLog(@"DELETE STORAGE cookie Name: %@, \nValue: %@, \nExpires: %@\n",
                                                            ((NSHTTPCookie *)cookie).name,
                                                            ((NSHTTPCookie *)cookie).value,
                                                            ((NSHTTPCookie *)cookie).expiresDate);
                                                      
                                                      
                                                      [storage deleteCookie:cookie];
                                                  }
                                                  
                                                  [[NSURLCache sharedURLCache] removeAllCachedResponses];
                                                  
                                                  [[NSUserDefaults standardUserDefaults] synchronize];
                                              }
                                              
                                              
                                              {
                                                  NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                                                  
                                                  NSLog(@"-------------------------------- %@", [storage.cookies autoDescription]);
                                                  
                                                  for (NSHTTPCookie *cookie in storage.cookies)
                                                  {
                                                      NSLog(@"-------------------------------- DELETE STORAGE cookie Name: %@, \nValue: %@, \nExpires: %@\n",
                                                            ((NSHTTPCookie *)cookie).name,
                                                            ((NSHTTPCookie *)cookie).value,
                                                            ((NSHTTPCookie *)cookie).expiresDate);
                                                  }
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
