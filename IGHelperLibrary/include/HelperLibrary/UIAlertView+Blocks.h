//
//  UIAlertView+Blocks.h
//

#import <UIKit/UIKit.h>

typedef void(^UIAlertViewHandler)(UIAlertView *alertView, NSInteger buttonIndex);

@interface UIAlertView (Blocks)

- (void)showWithHandler:(UIAlertViewHandler)handler;

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
              handler:(UIAlertViewHandler)handler;

+ (void)showErrorWithMessage:(NSString *)message handler:(UIAlertViewHandler)handler;

+ (void)showWarningWithMessage:(NSString *)message handler:(UIAlertViewHandler)handler;

+ (void)showInfoWithMessage:(NSString *)message handler:(UIAlertViewHandler)handler;

+ (void)showConfirmationDialogWithTitle:(NSString *)title
                                message:(NSString *)message
                                handler:(UIAlertViewHandler)handler;

@end
