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

@protocol AddOOOFormTableViewControllerDelegate;
@interface AddOOOFormTableViewController : UITableViewController <RequestTypeTableViewControllerDelegate, ExplanationViewControllerDelegate, NSURLConnectionDelegate, UIActionSheetDelegate>
{

    NSInteger currentUnCollapsedPickerIndex;
    NSNumber *freedays;
}
@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) id<AddOOOFormTableViewControllerDelegate> delegate;

@property (copy, nonatomic) NSString *explanation;
@property (nonatomic, assign) NSInteger currentType;
@property (nonatomic, assign) RequestType currentRequest;

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

@property (weak, nonatomic) IBOutlet UITextView *absenceHolidayExplanation;

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

@property (weak, nonatomic) IBOutlet UITextView *OOOExplanation;

// actions
- (IBAction)dateTimeValueChanged:(UIDatePicker *)sender;

@end


@protocol AddOOOFormTableViewControllerDelegate <NSObject>

- (void)didFinishAddingOOO;

@end