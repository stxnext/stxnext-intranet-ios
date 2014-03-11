//
//  TextInputViewController.h
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextInputViewControllerDelegate;
@interface TextInputViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextView *inputTextView;
@property (strong, nonatomic) id<TextInputViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString *inputText;
@property (nonatomic, assign) NSUInteger type;

@end

@protocol TextInputViewControllerDelegate <NSObject>

- (void)textInputViewController:(TextInputViewController *)textInputViewController didFinishWithResult:(NSString *)result;

@end
