//
//  LatenessViewController.h
//  Intranet
//
//  Created by Paweł Urbanowicz on 08.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LatenessViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *submitBottomPadButton;

@property (weak, nonatomic) IBOutlet UIView *lateWrapper;
@property (weak, nonatomic) IBOutlet UILabel *lateLabel;

@property (weak, nonatomic) IBOutlet UITextField *explanationField;
@property (weak, nonatomic) IBOutlet UIImageView *lateImage;
@property (weak, nonatomic) IBOutlet UILabel *fingerLabel;

@end
