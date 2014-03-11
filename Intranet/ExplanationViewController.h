//
//  ExplanationViewController.h
//  Intranet
//
//  Created by Adam on 25.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExplanationViewControllerDelegate;
@interface ExplanationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) id<ExplanationViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString *explanation;

@end


@protocol ExplanationViewControllerDelegate <NSObject>

- (void)explanationViewController:(ExplanationViewController *)explanationViewController didFinishWithExplanation:(NSString *)explanation;

@end
