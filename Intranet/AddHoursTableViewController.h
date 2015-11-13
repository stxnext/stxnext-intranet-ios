//
//  AddHoursTableViewController.h
//  Intranet
//
//  Created by Paweł Urbanowicz on 13.11.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddHoursTableViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSArray *projectsList;

@end
