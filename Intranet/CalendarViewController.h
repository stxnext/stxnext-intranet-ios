//
//  CalendarViewController.h
//  Intranet
//
//  Created by Paweł Urbanowicz on 18.11.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarViewController : UIViewController

@property (weak, nonatomic) NSDate *startDate;
@property (weak, nonatomic) NSDate *endDate;

@end
