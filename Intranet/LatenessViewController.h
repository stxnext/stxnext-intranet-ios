//
//  LatenessViewController.h
//  Intranet
//
//  Created by Paweł Urbanowicz on 08.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LatenessViewControllerDelegate <NSObject>

- (void)didFinishLatenessProcess;

@end

@interface LatenessViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<LatenessViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *submitBottomPadButton;

@property (weak, nonatomic) IBOutlet UIView *lateWrapper;
@property (weak, nonatomic) IBOutlet UILabel *lateLabel;

@property (weak, nonatomic) IBOutlet UITextField *explanationField;
@property (weak, nonatomic) IBOutlet UIImageView *lateImage;
@property (weak, nonatomic) IBOutlet UILabel *fingerLabel;

- (NSDate *)latenessEndDate;

@end
