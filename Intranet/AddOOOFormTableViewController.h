//
//  AddOOOFormTableViewController.h
//  Intranet
//
//  Created by Adam on 24.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestTypeTableViewController.h"
#import "ExplanationViewController.h"

typedef enum
{
    RequestTypeAbsenceHoliday,
    RequestTypeOutOfOffice
}RequestType;

@interface AddOOOFormTableViewController : UITableViewController <RequestTypeTableViewControllerDelegate, ExplanationViewControllerDelegate, NSURLConnectionDelegate>
{
    RequestType currentRequest;
    NSInteger currentUnCollapsedPickerIndex;

}

@property (copy, nonatomic) NSString *explanation;
@property (nonatomic, assign) NSInteger currentType;


// 0' section
// cells
@property (weak, nonatomic) IBOutlet UITableViewCell *absenceHolidayCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *OOOCell;


// 1' section
// cells
@property (weak, nonatomic) IBOutlet UITableViewCell *absenceHolidayCellStart;
@property (weak, nonatomic) IBOutlet UITableViewCell *absenceHolidayCellStartPicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *absenceHolidayCellEnd;
@property (weak, nonatomic) IBOutlet UITableViewCell *absenceHolidayCellEndPicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *absenceHolidayCellType;
@property (weak, nonatomic) IBOutlet UITableViewCell *absenceHolidayCellExplanation;

// pickers
@property (weak, nonatomic) IBOutlet UIDatePicker *absenceHolidayPickerStart;
@property (weak, nonatomic) IBOutlet UIDatePicker *absenceHolidayPickerEnd;


// 2' section
// cells
@property (weak, nonatomic) IBOutlet UITableViewCell *OOOCellDate;
@property (weak, nonatomic) IBOutlet UITableViewCell *OOOCellDatePicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *OOOCellFrom;
@property (weak, nonatomic) IBOutlet UITableViewCell *OOOCellFromPicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *OOOCellTo;
@property (weak, nonatomic) IBOutlet UITableViewCell *OOOCellToPicker;
@property (weak, nonatomic) IBOutlet UITableViewCell *OOOCellWorkFromHome;
@property (weak, nonatomic) IBOutlet UITableViewCell *OOOCellExplanation;

// pickers
@property (weak, nonatomic) IBOutlet UIDatePicker *OOOPickerDate;
@property (weak, nonatomic) IBOutlet UIDatePicker *OOOPickerFrom;
@property (weak, nonatomic) IBOutlet UIDatePicker *OOOPickerTo;


// actions
- (IBAction)dateTimeValueChanged:(UIDatePicker *)sender;

@end
