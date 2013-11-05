//
//  UIAlertView+CustomAlert.h
//  Intranet
//
//  Created by Dawid Zakowski on 11/2/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (CustomAlert)

+ (void)alertWithTitle:(NSString*)title
              withText:(NSString*)text;

@end
