//
//  AddOOOFormTableViewController.m
//  Intranet
//
//  Created by Adam on 24.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "AddOOOFormTableViewController.h"
#import "APIRequest.h"
#import "AppDelegate+Navigation.h"

#define NEW_MENU YES
#define MIN_TIME_DIFF 900 //defines (in seconds) minimum time interval between ooo 'from' and 'to' dates

typedef enum
{
    DateTimeTypeAbsenceHolidayStart = 12,
    DateTimeTypeAbsenceHolidayEnd = 14,
    DateTimeTypeOOODate = 22,
    DateTimeTypeOOOFrom = 24,
    DateTimeTypeOOOTo = 26
}DateTimeType;

@interface AddOOOFormTableViewController ()

@end

@implementation AddOOOFormTableViewController

- (void)viewDidLoad
{
    self.title = @"New Request";
    
    [super viewDidLoad];
    
    if (!NEW_MENU)
    {
        self.currentType = 0;
    }
    
    if (INTERFACE_IS_PAD) {
        NSString *title = self.currentRequest == RequestTypeAbsenceHoliday ? @"Absence/Holiday" : @"Out of office";
        
        [self.navigationItem setTitle:title];
    }
    
    self.absenceHolidayCellType.detailTextLabel.text = @"Planned leave";
    
    self.OOOPickerFrom.minimumDate = self.OOOPickerTo.minimumDate = self.OOOPickerDate.minimumDate = self.absenceHolidayPickerStart.minimumDate = self.absenceHolidayPickerEnd.minimumDate = [[NSDate date] dateWithHour:0 minute:0 second:0];
    
    NSDate *today = [NSDate date];
    self.OOOPickerDate.date = self.absenceHolidayPickerStart.date = self.absenceHolidayPickerEnd.date = today;
    self.OOOPickerFrom.date = [today dateWithHour:9 minute:0 second:0];
    self.OOOPickerTo.date = [today dateWithHour:17 minute:0 second:0];
    
    if (self.currentRequest == RequestTypeAbsenceHoliday)
    {
        [self getFreeDays];
    }
    
    [self dateTimeValueChanged:self.absenceHolidayPickerStart];
    [self dateTimeValueChanged:self.absenceHolidayPickerEnd];
    [self dateTimeValueChanged:self.OOOPickerDate];
    [self dateTimeValueChanged:self.OOOPickerFrom];
    [self dateTimeValueChanged:self.OOOPickerTo];
    
    currentUnCollapsedPickerIndex = -1;
    
    if (!NEW_MENU)
    {
        self.currentRequest = RequestTypeAbsenceHoliday;
    }
    
    self.submitCell.backgroundColor = [UIColor clearColor];
    [self updateTableView];
}

- (IBAction)cancel:(id)sender
{
    if (INTERFACE_IS_PHONE)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self.popover dismissPopoverAnimated:YES];
    }
}

- (IBAction)done:(id)sender
{
    if ([RMUser userLoggedType] == UserLoginTypeTrue)
    {
        
        ((UIButton *)sender).enabled = NO;
        
        switch (self.currentRequest)
        {
            case RequestTypeAbsenceHoliday:
            {
                NSString *popup_type = nil;
                
                if ([self.absenceHolidayCellType.detailTextLabel.text isEqualToString:NSLocalizedString(@"Planned leave", nil)])
                {
                    popup_type = @"planowany";
                }
                else if ([self.absenceHolidayCellType.detailTextLabel.text isEqualToString:NSLocalizedString(@"Leave at request", nil)])
                {
                    popup_type = @"zadanie";
                }
                else if ([self.absenceHolidayCellType.detailTextLabel.text isEqualToString:NSLocalizedString(@"Illness", nil)])
                {
                    popup_type = @"l4";
                }
                else if ([self.absenceHolidayCellType.detailTextLabel.text isEqualToString:NSLocalizedString(@"Compassionate leave", nil)])
                {
                    popup_type = @"okolicznosciowy";
                }
                else if ([self.absenceHolidayCellType.detailTextLabel.text isEqualToString:NSLocalizedString(@"Absence", nil)])
                {
                    popup_type = @"inne";
                }
                
                
                UITextView *tField = self.absenceHolidayExplanation;
                NSString *explanation;
                if (INTERFACE_IS_PAD) {
                    explanation = [tField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                } else {
                    explanation = [self.explanation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
                
                popup_type = [popup_type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *from = [self.absenceHolidayCellStart.detailTextLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *to = [self.absenceHolidayCellEnd.detailTextLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if (from.length && to.length && popup_type.length && [explanation length])
                {
                    if (![[from componentsSeparatedByString:@"/"][1] isEqualToString:[to componentsSeparatedByString:@"/"][1]])
                    {
                        [UIAlertView showWithTitle:@"Info"
                                           message:@"Please split the date into 2 months."
                                             style:UIAlertViewStyleDefault
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@[@"OK"]
                                          tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                 }];
                        
                        return;
                    }
                    
                    NSDictionary *innerJSON = [NSDictionary dictionaryWithObjects:@[popup_type,
                                                                                    from,
                                                                                    to,
                                                                                    explanation]
                                                                          forKeys:@[@"popup_type",
                                                                                    @"popup_date_start",
                                                                                    @"popup_date_end",
                                                                                    @"popup_remarks"]];
                    
                    NSDictionary *JSON = [NSDictionary dictionaryWithObject:innerJSON forKey:@"absence"];
                    
                    [[HTTPClient sharedClient] startOperation:[APIRequest sendAbsence:JSON]
                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        if ([self.delegate respondsToSelector:@selector(didFinishAddingOOO)])
                        {
                            [self.delegate didFinishAddingOOO];
                        }
                        
                        if (INTERFACE_IS_PHONE)
                        {
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }
                        else
                        {
//                            [self.popover dismissPopoverAnimated:YES];
                        }
                                                          
                          ((UIButton *)sender).enabled = YES;
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        
                        [UIAlertView showWithTitle:@"Error"
                                           message:@"Request has not been added. Please try again."
                                             style:UIAlertViewStyleDefault
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                 }];
                        
                        ((UIButton *)sender).enabled = YES;
                    }];
                }
                else
                {
                    [UIAlertView showWithTitle:@"Info"
                                       message:@"All fields required."
                                         style:UIAlertViewStyleDefault
                             cancelButtonTitle:nil
                             otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                             }];
                    
                    ((UIButton *)sender).enabled = YES;
                }
            }
                break;
                
            case RequestTypeOutOfOffice:
            {
                UITextView *tField = self.OOOExplanation;
                
                NSString *explanation;
                if (INTERFACE_IS_PAD) {
                    explanation = [tField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                } else {
                    explanation = [self.explanation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
                
                NSString *from = [self.OOOCellFrom.detailTextLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *to = [self.OOOCellTo.detailTextLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *date = [self.OOOCellDate.detailTextLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if (from.length && to.length && date.length && [explanation length] > 0)
                {
                    NSDictionary *innerJSON = [NSDictionary dictionaryWithObjects:@[from,
                                                                                    to,
                                                                                    date,
                                                                                    [NSNumber numberWithBool:self.OOOCellWorkFromHome.accessoryType == UITableViewCellAccessoryCheckmark],
                                                                                    explanation]
                                                                          forKeys:@[@"late_start",
                                                                                    @"late_end",
                                                                                    @"popup_date",
                                                                                    @"work_from_home",
                                                                                    @"popup_explanation"]];
                    
                    NSDictionary *JSON = [NSDictionary dictionaryWithObject:innerJSON forKey:@"lateness"];
                    
                    [[HTTPClient sharedClient] startOperation:[APIRequest sendLateness:JSON]
                                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        
                        if ([self.delegate respondsToSelector:@selector(didFinishAddingOOO)])
                        {
                            [self.delegate didFinishAddingOOO];
                        }

                        if (INTERFACE_IS_PHONE)
                        {
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }
                        else
                        {
//                            [self.popover dismissPopoverAnimated:YES];
                        }
                      ((UIButton *)sender).enabled = YES;

                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        
                        [UIAlertView showWithTitle:@"Error"
                                           message:@"Request has not been added. Please try again."
                                             style:UIAlertViewStyleDefault
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                 }];
                        
                        ((UIButton *)sender).enabled = YES;
                    }];
                }
                else
                {
                    [UIAlertView showWithTitle:@"Info"
                                       message:@"All fields required."
                                         style:UIAlertViewStyleDefault
                             cancelButtonTitle:nil
                             otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                             }];
                    
                    ((UIButton *)sender).enabled = YES;
                }
            }
                break;
        }
    }
    else
    {
        [self cancel:nil];
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(NEW_MENU)
    {
        if (indexPath.section == 0)
        {
            return 0;
        }
    }
    
    if (indexPath.section == 1)
    {
        if (self.currentRequest == RequestTypeOutOfOffice)
        {
            return 0;
        }
        else if (indexPath.row == currentUnCollapsedPickerIndex)
        {
            return 162;
        }
        else if (indexPath.row == 1 || indexPath.row == 3)
        {
            return 0 ;
        }
        else if (indexPath.row == 5)
        {
            return 80.f;
        }
    }
    
    if (indexPath.section == 2)
    {
        if (self.currentRequest == RequestTypeAbsenceHoliday)
        {
            return 0;
        }
        else if (indexPath.row == currentUnCollapsedPickerIndex)
        {
            return 162;
        }
        else if (indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5)
        {
            return 0;
        }
        else if (indexPath.row == 7)
        {
            return 80.f;
        }
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    if (INTERFACE_IS_PAD) {
        [self paintHeaderFooter:view OnColor:[Branding stxLightGray]];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (INTERFACE_IS_PAD) {
        [self paintHeaderFooter:view OnColor:[Branding stxLightGray]];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        return NO;
    }
    return YES;
}

- (void)paintHeaderFooter:(UIView *)view OnColor:(UIColor *)bcgColor
{
    if ([view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView *hfView = (UITableViewHeaderFooterView *)view;
        hfView.contentView.backgroundColor = bcgColor;
        hfView.backgroundView.backgroundColor = bcgColor;
    } else {
        view.backgroundColor = bcgColor;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0 && self.currentRequest != RequestTypeAbsenceHoliday)
        {
            currentUnCollapsedPickerIndex = -1;
            self.currentRequest = RequestTypeAbsenceHoliday;
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self updateTableView];
        }
        else if (indexPath.row == 1 && self.currentRequest != RequestTypeOutOfOffice)
        {
            currentUnCollapsedPickerIndex = -1;
            self.currentRequest = RequestTypeOutOfOffice;
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self updateTableView];
        }
        else
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == currentUnCollapsedPickerIndex - 1)
        {
            currentUnCollapsedPickerIndex = -1;
            
            self.absenceHolidayCellStartPicker.hidden = YES;
            self.absenceHolidayCellEndPicker.hidden = YES;
            
            [self.tableView reloadData];
        }
        else if (indexPath.row == 0 || indexPath.row == 2)
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            currentUnCollapsedPickerIndex = indexPath.row + 1;
            
            self.absenceHolidayCellStartPicker.hidden = currentUnCollapsedPickerIndex != 1;
            self.absenceHolidayCellEndPicker.hidden = currentUnCollapsedPickerIndex != 3;
            
            [self.tableView reloadData];
        }
        else if ([[self tableView:tableView cellForRowAtIndexPath:indexPath] isEqual:self.absenceHolidayCellType])
        {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            UIActionSheet *typeActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                         delegate:self
                                                                cancelButtonTitle:nil
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:NSLocalizedString(@"Planned leave", nil), NSLocalizedString(@"Leave at request", nil), NSLocalizedString(@"Illness", nil), NSLocalizedString(@"Compassionate leave", nil), NSLocalizedString(@"Absence", nil), nil];
            
            if(INTERFACE_IS_PHONE) {
                [typeActionSheet showInView:self.view];
            } else {
                CGRect rectCell = [tableView rectForRowAtIndexPath:indexPath];
                CGRect rect = [tableView convertRect:rectCell toView:self.view];
                [typeActionSheet showFromRect:rect inView:self.view animated:YES];
            }
        }
        else if ([[self tableView:tableView cellForRowAtIndexPath:indexPath] isEqual:self.absenceHolidayCellExplanation])
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIAlertView *explanationAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Remarks", nil)
                                                                       message:NSLocalizedString(@"Please leave information about your availability via email or phone.", nil)
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                             otherButtonTitles:@"OK", nil];
            
            explanationAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [explanationAlert show];
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == currentUnCollapsedPickerIndex - 1)
        {
            currentUnCollapsedPickerIndex = -1;
            
            self.OOOCellDatePicker.hidden = YES;
            self.OOOCellFromPicker.hidden = YES;
            self.OOOCellToPicker.hidden = YES;
            
            [self.tableView reloadData];
        }
        else if ([[self tableView:tableView cellForRowAtIndexPath:indexPath] isEqual:self.OOOCellExplanation])
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            UIAlertView *explanationAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Explanation", nil)
                                                                       message:NSLocalizedString(@"Please leave your explanation below.", nil)
                                                                      delegate:self
                                                             cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                             otherButtonTitles:@"OK", nil];
            
            explanationAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
            [explanationAlert show];
        }
        else if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 4)
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            currentUnCollapsedPickerIndex = indexPath.row + 1;
            
            self.OOOCellDatePicker.hidden = currentUnCollapsedPickerIndex != 1;
            self.OOOCellFromPicker.hidden = currentUnCollapsedPickerIndex != 3;
            self.OOOCellToPicker.hidden = currentUnCollapsedPickerIndex != 5;
            
            [self.tableView reloadData];
        }
        else if (indexPath.row == 6)
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *explanation = [[[alertView textFieldAtIndex:0] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(buttonIndex == 1 && [explanation length] > 0)
    {
        self.explanation = explanation;
        if(self.OOOCellExplanation) self.OOOCellExplanation.detailTextLabel.text = explanation;
        if(self.absenceHolidayCellExplanation) self.absenceHolidayCellExplanation.detailTextLabel.text = explanation;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) [self.tableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= 0) {
        self.currentType = buttonIndex;
        self.absenceHolidayCellType.detailTextLabel.text = [actionSheet buttonTitleAtIndex:buttonIndex];
    }
}

- (void)updateTableView
{
    if (NEW_MENU)
    {
        self.absenceHolidayCell.hidden = YES;
        self.OOOCell.hidden = YES;
    }
    
    self.absenceHolidayCell.accessoryType = UITableViewCellAccessoryNone;
    self.OOOCell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (self.currentRequest)
    {
        case RequestTypeAbsenceHoliday:
        {
            self.absenceHolidayCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            self.absenceHolidayCellStart.hidden = NO;
            self.absenceHolidayCellStartPicker.hidden = YES;
            self.absenceHolidayCellEnd.hidden = NO;
            self.absenceHolidayCellEndPicker.hidden = YES;
            self.absenceHolidayCellType.hidden = NO;
            self.absenceHolidayCellExplanation.hidden = NO;
            
            self.OOOCellDate.hidden = YES;
            self.OOOCellDatePicker.hidden = YES;
            self.OOOCellFrom.hidden = YES;
            self.OOOCellFromPicker.hidden = YES;
            self.OOOCellTo.hidden = YES;
            self.OOOCellToPicker.hidden = YES;
            self.OOOCellWorkFromHome.hidden = YES;
            self.OOOCellExplanation.hidden = YES;
            
            [self performBlockOnMainThread:^{
                [self.tableView reloadData];
            } afterDelay:0.5];
        }
            break;
            
        case RequestTypeOutOfOffice:
        {
            self.OOOCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            self.absenceHolidayCellStart.hidden = YES;
            self.absenceHolidayCellStartPicker.hidden = YES;
            self.absenceHolidayCellEnd.hidden = YES;
            self.absenceHolidayCellEndPicker.hidden = YES;
            self.absenceHolidayCellType.hidden = YES;
            self.absenceHolidayCellExplanation.hidden = YES;
            
            self.OOOCellDate.hidden = NO;
            self.OOOCellDatePicker.hidden = YES;
            self.OOOCellFrom.hidden = NO;
            self.OOOCellFromPicker.hidden = YES;
            self.OOOCellTo.hidden = NO;
            self.OOOCellToPicker.hidden = YES;
            self.OOOCellWorkFromHome.hidden = NO;
            self.OOOCellExplanation.hidden = NO;

            [self performBlockOnMainThread:^{
                [self.tableView reloadData];
            } afterDelay:0.5];
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            if (NEW_MENU)
            {
                return 0.00001;
            }
            
            return 44;
        }
            break;
            
        case 1:
        {
            if (self.currentRequest == RequestTypeAbsenceHoliday)
            {
                return 22;
            }
        }
            break;
            
        case 2:
        {
            if (self.currentRequest == RequestTypeOutOfOffice)
            {
                return 22;
            }
        }
            break;
    }
    
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            if (!NEW_MENU)
            {
                return 0.01;
            }
            
            return 22;
        }
            break;
            
        case 1:
        {
            if (self.currentRequest == RequestTypeAbsenceHoliday)
            {
                return 22;
            }
        }
            break;
            
        case 2:
        {
            if (self.currentRequest == RequestTypeOutOfOffice)
            {
                return 22;
            }
        }
            break;
    }
    
    return 0.0001;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            if (NEW_MENU)
            {
                return nil;
            }
            
            return @"REQUEST FOR";
        }
            break;
            
        case 1:
        {
            if (self.currentRequest == RequestTypeAbsenceHoliday)
            {
                return [NSString stringWithFormat:@"ABSENCE / HOLIDAY - %@ days left", freedays?: @" "];
            }
        }
            break;
            
        case 2:
        {
            if (self.currentRequest == RequestTypeOutOfOffice)
            {
                return @"OUT OF OFFICE";
            }
        }
            break;
    }
    
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[RequestTypeTableViewController class]])
    {
        ((RequestTypeTableViewController *)segue.destinationViewController).currentType = self.currentType;
        ((RequestTypeTableViewController *)segue.destinationViewController).delegate = self;
    }
    else if ([segue.destinationViewController isKindOfClass:[ExplanationViewController class]])
    {
        ((ExplanationViewController *)segue.destinationViewController).explanation = self.explanation;
        ((ExplanationViewController *)segue.destinationViewController).delegate = self;
    }
}

#pragma mark -  RequestTypeTableViewControllerDelegate

- (void)requestTypeTableViewController:(RequestTypeTableViewController *)requestTypeTableViewController didSelectTypeWith:(NSInteger)typeId type:(NSString *)type
{
    self.currentType = typeId;
    self.absenceHolidayCellType.detailTextLabel.text = type;
}

#pragma mark -  RequestTypeTableViewControllerDelegate   

- (void)explanationViewController:(ExplanationViewController *)explanationViewController explanation:(NSString *)explanation
{
    self.explanation = explanation;
    self.absenceHolidayCellExplanation.detailTextLabel.text = self.OOOCellExplanation.detailTextLabel.text = self.explanation;
}

- (IBAction)dateTimeValueChanged:(UIDatePicker *)sender
{
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    
    switch (sender.tag)
    {
        case DateTimeTypeAbsenceHolidayStart:
        case DateTimeTypeAbsenceHolidayEnd:
        case DateTimeTypeOOODate:
        {
            dateFormater.dateFormat = @"dd/MM/yyyy";
        }
            break;
            
        case DateTimeTypeOOOFrom:
        case DateTimeTypeOOOTo:
        {
            dateFormater.dateFormat = @"HH:mm";
        }
            break;
    }
    
    switch (sender.tag)
    {
        case DateTimeTypeAbsenceHolidayStart:
        {
            if ([self.absenceHolidayPickerStart.date compare:[NSDate date]] == NSOrderedAscending)
            {
                [self.absenceHolidayPickerStart setDate:[NSDate date] animated:YES];
            }
            
            self.absenceHolidayCellStart.detailTextLabel.text = [dateFormater stringFromDate:self.absenceHolidayPickerStart.date];
            
            if ([self.absenceHolidayPickerEnd.date compare:self.absenceHolidayPickerStart.date] ==  NSOrderedAscending)
            {
                [self.absenceHolidayPickerEnd setDate:self.absenceHolidayPickerStart.date animated:YES];
                self.absenceHolidayCellEnd.detailTextLabel.text = [dateFormater stringFromDate:self.absenceHolidayPickerStart.date];
            }
        }
            break;
            
        case DateTimeTypeAbsenceHolidayEnd:
        {
            if ([self.absenceHolidayPickerEnd.date compare:self.absenceHolidayPickerStart.date] ==  NSOrderedAscending)
            {
                [self.absenceHolidayPickerEnd setDate:self.absenceHolidayPickerStart.date animated:YES];
            }
            
            self.absenceHolidayCellEnd.detailTextLabel.text = [dateFormater stringFromDate:self.absenceHolidayPickerEnd.date];
        }
            break;
            
        case DateTimeTypeOOODate:
        {
            if ([self.OOOPickerDate.date compare:[NSDate date]] == NSOrderedAscending)
            {
                [self.OOOPickerDate setDate:[NSDate date] animated:YES];
            }
            
            self.OOOCellDate.detailTextLabel.text = [dateFormater stringFromDate:self.OOOPickerDate.date];
        }
            break;
            
        case DateTimeTypeOOOFrom:
        {
            self.OOOCellFrom.detailTextLabel.text = [dateFormater stringFromDate:sender.date];
            
            if ([self.OOOPickerTo.date compare:self.OOOPickerFrom.date] !=  NSOrderedDescending)
            {
                [self.OOOPickerTo setDate:[self.OOOPickerFrom.date dateByAddingTimeInterval:MIN_TIME_DIFF] animated:YES];
                self.OOOCellTo.detailTextLabel.text = [dateFormater stringFromDate:self.OOOPickerTo.date];
            }
        }
            break;
            
        case DateTimeTypeOOOTo:
        {
            if ([self.OOOPickerTo.date compare:self.OOOPickerFrom.date] !=  NSOrderedDescending)
            {
                [self.OOOPickerTo setDate:[self.OOOPickerFrom.date dateByAddingTimeInterval:MIN_TIME_DIFF] animated:YES];
            }
            
            self.OOOCellTo.detailTextLabel.text = [dateFormater stringFromDate:self.OOOPickerTo.date];
        }
            break;
    }
    
    [self.tableView reloadData];
}

- (void)getFreeDays
{
    [[HTTPClient sharedClient] startOperation:[APIRequest getFreeDays] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        freedays = [responseObject objectForKey:@"left"];
        
        if (!NEW_MENU)
        {
            self.absenceHolidayCell.detailTextLabel.text = [NSString stringWithFormat:@"%@ days left", freedays];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0] ] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

- (void)setCurrentRequest:(RequestType)currentRequest
{
    _currentRequest = currentRequest;
    self.currentType = currentRequest;
}

@end
