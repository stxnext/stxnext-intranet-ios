//
//  LatenessViewController.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 08.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "LatenessViewController.h"
#import "APIRequest.h"

#define MAX_LATENESS 2 //maximum lateness diff in hours, default 2
#define SECS_PER_HOUR 3600

@implementation LatenessViewController
{
    NSDate *startDate; //default date, set as 9:00 AM
    NSDate *endDate;
}

- (NSDate *)latenessEndDate
{
    return endDate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.explanationField setDelegate:self];
    
    [self setDefaults];
    [self setGestureRecognizer];
}

- (void)setDefaults
{
    [self.navigationItem setTitle:NSLocalizedString(@"New request", nil)];
    [self.explanationField setPlaceholder:NSLocalizedString(@"Lateness reason", nil)];
    [self.fingerLabel setText:NSLocalizedString(@"Move your finger!", nil)];
    
    if (INTERFACE_IS_PHONE) {
        [self.submitButton setEnabled:NO];
    } else {
        
        [self.submitBottomPadButton setTitle:NSLocalizedString(@"Submit", nil)
                                    forState:UIControlStateNormal];
        [self.submitBottomPadButton setEnabled:NO];
    }
    
    startDate = [[NSDate date] dateWithHour:9 minute:0 second:0];
    endDate = startDate; //by default end date is equal to start date

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    [self.lateLabel setText:[dateFormatter stringFromDate:startDate]];
}

#pragma mark gesture recognizer

- (void)setGestureRecognizer
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragLateness:)];
    [panGesture setMinimumNumberOfTouches:1];
    [panGesture setMaximumNumberOfTouches:1];
    [panGesture setDelegate:self];
    
    [self.view addGestureRecognizer:panGesture];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)dragLateness:(id)sender
{
    UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer*)sender;
    CGPoint location = [gesture locationInView:self.lateImage];
    
    if(!CGRectContainsPoint(self.lateImage.bounds, location)) return;
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        if(![self.fingerLabel isHidden])
        {
            [self.fingerLabel setHidden:YES];
            [self.lateImage setImage:[UIImage imageNamed:@"zzzz"]];
            [self.lateImage setAlpha:0.0];
        }
    }
    if(gesture.state == UIGestureRecognizerStateChanged)
    {
        CGFloat deadzone = self.lateImage.frame.size.width * 0.05; //touch won't be detected in this area, measured both for left & right edge
        CGFloat coverPercentage = ((location.x - deadzone) / (self.lateImage.frame.size.width - 2*deadzone));
        
        //if we're out of frame just fix it
        if(coverPercentage < 0) coverPercentage = 0;
        else if(coverPercentage > 1) coverPercentage = 1;
        
        [self.lateWrapper setBackgroundColor:[self greenColorForPercentage:coverPercentage]];
        [self.lateImage setAlpha:coverPercentage];
        
        NSInteger lateMinutes = coverPercentage * MAX_LATENESS * SECS_PER_HOUR;
        NSLog(@"%f",coverPercentage);
        endDate = [startDate dateByAddingTimeInterval:lateMinutes];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm"];
        [self.lateLabel setText:[dateFormatter stringFromDate:endDate]];
    }
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        if (INTERFACE_IS_PHONE) {
            if([endDate isEqualToDate:startDate]) [self.submitButton setEnabled:NO];
            else [self.submitButton setEnabled:YES];
        } else {
            
            if([endDate isEqualToDate:startDate]) [self.submitBottomPadButton setEnabled:NO];
            else [self.submitBottomPadButton setEnabled:YES];
        }
    }
}

- (UIColor *)greenColorForPercentage:(CGFloat)percentage
{
    const CGFloat *lightGreen = CGColorGetComponents([[Branding stxGreen] CGColor]);
    const CGFloat *darkGreen = CGColorGetComponents([[Branding stxDarkGreen] CGColor]);
    
    CGFloat myRed = lightGreen[0] + percentage * (darkGreen[0] - lightGreen[0]);
    CGFloat myGreen = lightGreen[1] + percentage * (darkGreen[1] - lightGreen[1]);
    CGFloat myBlue = lightGreen[2] + percentage * (darkGreen[2] - lightGreen[2]);

    return [UIColor colorWithRed:myRed green:myGreen blue:myBlue alpha:1.0];
}

#pragma mark action buttons

- (IBAction)closeForm:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitForm:(id)sender {
    if ([RMUser userLoggedType] == UserLoginTypeTrue)
    {
        [((UIButton *)sender) setEnabled:NO];
        [self.view setUserInteractionEnabled:NO];
        
        NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
        [hourFormatter setDateFormat:@"hh:mm"];
        
        NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
        [dayFormatter setDateFormat:@"dd/MM/yyyy"];
        
        NSString *explanation = (self.explanationField.text.length > 0) ? [self.explanationField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] : NSLocalizedString(@"I'll be late.", nil);
        NSString *from = [hourFormatter stringFromDate:startDate];
        NSString *to = [hourFormatter stringFromDate:endDate];
        NSString *date = [dayFormatter stringFromDate:startDate];
        
        if (from.length && to.length && date.length && explanation.length)
        {
            NSDictionary *innerJSON = [NSDictionary dictionaryWithObjects:@[from,
                                                                            to,
                                                                            date,
                                                                            [NSNumber numberWithBool:NO],
                                                                            explanation]
                                                                  forKeys:@[@"late_start",
                                                                            @"late_end",
                                                                            @"popup_date",
                                                                            @"work_from_home",
                                                                            @"popup_explanation"]];
            
            
            NSDictionary *JSON = [NSDictionary dictionaryWithObject:innerJSON forKey:@"lateness"];
            
            [[HTTPClient sharedClient] startOperation:[APIRequest sendLateness:JSON] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                if (INTERFACE_IS_PHONE)
                {
                    [self closeForm:self];
                } else {
                    
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishLatenessProcess)]) {
                    [self.delegate didFinishLatenessProcess];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [UIAlertView showWithTitle:NSLocalizedString(@"Error", nil)
                                   message:NSLocalizedString(@"Request has not been added. Please try again.",nil)
                                     style:UIAlertViewStyleDefault
                         cancelButtonTitle:nil
                         otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                         }];
                
                [((UIButton *)sender) setEnabled:YES];
                [self.view setUserInteractionEnabled:YES];
            }];
        }
        else
        {
            [UIAlertView showWithTitle:NSLocalizedString(@"Info", nil)
                               message:NSLocalizedString(@"All fields required.", nil)
                                 style:UIAlertViewStyleDefault
                     cancelButtonTitle:nil
                     otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                     }];
            
            [((UIButton *)sender) setEnabled:YES];
            [self.view setUserInteractionEnabled:YES];
        }
    }
    else
    {
        [self closeForm:self];
    }
}

@end
