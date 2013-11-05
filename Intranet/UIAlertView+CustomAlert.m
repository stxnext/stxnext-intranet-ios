//
//  UIAlertView+CustomAlert.m
//  Intranet
//
//  Created by Dawid Zakowski on 11/2/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UIAlertView+CustomAlert.h"

@implementation UIAlertView (CustomAlert)

+ (void)alertWithTitle:(NSString*)title
              withText:(NSString*)text
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [alert show];
}

@end
