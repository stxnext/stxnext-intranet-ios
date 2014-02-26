//
//  AddOOOFormTableViewController.m
//  Intranet
//
//  Created by Adam on 24.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "AddOOOFormTableViewController.h"
#import "APIRequest.h"

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
    self.currentType = -1;
    
    self.OOOFromPicker.minimumDate = self.OOOToPicker.minimumDate = self.OOODatePicker.minimumDate = self.absenceHolidayStartPicker.minimumDate = self.absenceHolidayEndPicker.minimumDate = [[NSDate date] dateWithHour:0 minute:0 second:0];
    
    currentUnCollapsedPickerIndex = -1;
    currentRequest = RequestTypeAbsenceHoliday;
    [self updateTableView];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@ %@", connection, error);
}
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"%@ %@", connection, challenge);
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@ %@", connection, response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"%@ %@", connection, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    //    [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"%@", connection);
    //    NSLog(@"response data - %@", [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding]);
}

- (IBAction)done:(id)sender
{
    
    switch (currentRequest)
    {
        case RequestTypeAbsenceHoliday:
        {
            NSString *popup_type = nil;
            
            if ([self.absenceHolidayCellType.detailTextLabel.text isEqualToString:@"Planned leave"])
            {
                popup_type = @"planowany";
            }
            else if ([self.absenceHolidayCellType.detailTextLabel.text isEqualToString:@"Leave at request"])
            {
                popup_type = @"zadanie";
            }
            else if ([self.absenceHolidayCellType.detailTextLabel.text isEqualToString:@"Illness"])
            {
                popup_type = @"l4";
            }
            else if ([self.absenceHolidayCellType.detailTextLabel.text isEqualToString:@"Compassionate leave"])
            {
                popup_type = @"okolicznosciowy";
            }
            else if ([self.absenceHolidayCellType.detailTextLabel.text isEqualToString:@"Absence"])
            {
                popup_type = @"inne";
            }
            
            self.explanation = [self.explanation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            popup_type = [popup_type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *from = [self.absenceHolidayCellStart.detailTextLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *to = [self.absenceHolidayCellEnd.detailTextLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (from.length && to.length && popup_type.length && self.explanation.length)
            {
                NSDictionary *innerJSON = [NSDictionary dictionaryWithObjects:@[popup_type,
                                                                                from,
                                                                                to,
                                                                                self.explanation]
                                                                      forKeys:@[@"popup_type",
                                                                                @"popup_date_start",
                                                                                @"popup_date_end",
                                                                                @"popup_remarks"]];
                
                NSDictionary *JSON = [NSDictionary dictionaryWithObject:innerJSON forKey:@"absence"];
                
                [[HTTPClient sharedClient] startOperation:[APIRequest sendAbsence:JSON] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                    //                NSLog(@"====================");
                    //                NSLog(@"%@", operation.responseString);
                    //                NSLog(@"%@", responseObject);
                    //                NSLog(@"====================");
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [UIAlertView showWithTitle:@"Error"
                                       message:@"New request adding failed"
                                         style:UIAlertViewStyleDefault
                             cancelButtonTitle:nil
                             otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                             }];
                    
                    //                NSLog(@"====================");
                    //                NSLog(@"%@", operation.responseString);
                    //                NSLog(@"%@", error);
                    //                NSLog(@"====================");
                }];
            }
            else
            {
                [UIAlertView showWithTitle:@"Info"
                                   message:@"All fields required"
                                     style:UIAlertViewStyleDefault
                         cancelButtonTitle:nil
                         otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                         }];
            }
        }
            break;
            
        case RequestTypeOutOfOffice:
        {
            self.explanation = [self.explanation stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *from = [self.OOOCellFrom.detailTextLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *to = [self.OOOCellTo.detailTextLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *date = [self.OOOCellDate.detailTextLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (from.length && to.length && date.length && self.explanation.length)
            {
                NSDictionary *innerJSON = [NSDictionary dictionaryWithObjects:@[from,
                                                                                to,
                                                                                date,
                                                                                [NSNumber numberWithBool:self.OOOCellWorkFromHome.accessoryType == UITableViewCellAccessoryCheckmark],
                                                                                self.explanation]
                                                                      forKeys:@[@"late_start",
                                                                                @"late_end",
                                                                                @"popup_date",
                                                                                @"work_from_home",
                                                                                @"popup_explanation"]];
                
                
                NSDictionary *JSON = [NSDictionary dictionaryWithObject:innerJSON forKey:@"lateness"];
                
                [[HTTPClient sharedClient] startOperation:[APIRequest sendLateness:JSON] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                    //                NSLog(@"====================");
                    //                NSLog(@"%@", operation.responseString);
                    //                NSLog(@"%@", responseObject);
                    //                NSLog(@"====================");
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [UIAlertView showWithTitle:@"Error"
                                       message:@"New request adding failed"
                                         style:UIAlertViewStyleDefault
                             cancelButtonTitle:nil
                             otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                             }];
                    
                    
                    //                NSLog(@"====================");
                    //                NSLog(@"%@", operation.responseString);
                    //                NSLog(@"%@", error);
                    //                NSLog(@"====================");
                }];
            }
            else
            {
                [UIAlertView showWithTitle:@"Info"
                                   message:@"All fields required"
                                     style:UIAlertViewStyleDefault
                         cancelButtonTitle:nil
                         otherButtonTitles:@[@"OK"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                         }];
            }
        }
            break;
    }
    
    
    
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (currentRequest == RequestTypeOutOfOffice)
        {
            return 0;
        }
        else if (indexPath.row == currentUnCollapsedPickerIndex)
        {
            return 162;
        }
        else if (indexPath.row == 1 || indexPath.row == 3)
        {
            return 0;
        }
    }
    
    if (indexPath.section == 2)
    {
        if (currentRequest == RequestTypeAbsenceHoliday)
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
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0 && currentRequest != RequestTypeAbsenceHoliday)
        {
            currentUnCollapsedPickerIndex = -1;
            currentRequest = RequestTypeAbsenceHoliday;
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self updateTableView];
        }
        else if (indexPath.row == 1 && currentRequest != RequestTypeOutOfOffice)
        {
            currentUnCollapsedPickerIndex = -1;
            currentRequest = RequestTypeOutOfOffice;
            
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
            [self.tableView reloadDataAnimated:YES];
        }
        else if (indexPath.row == 0 || indexPath.row == 2)
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            currentUnCollapsedPickerIndex = indexPath.row + 1;
            
            self.absenceHolidayCellStartPicker.hidden = currentUnCollapsedPickerIndex != 1;
            self.absenceHolidayCellEndPicker.hidden = currentUnCollapsedPickerIndex != 3;
            
            [self.tableView reloadDataAnimated:YES];
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == currentUnCollapsedPickerIndex - 1)
        {
            currentUnCollapsedPickerIndex = -1;
            [self.tableView reloadDataAnimated:YES];
        }
        else if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 4)
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            currentUnCollapsedPickerIndex = indexPath.row + 1;
            
            self.OOOCellDatePicker.hidden = currentUnCollapsedPickerIndex != 1;
            self.OOOCellFromPicker.hidden = currentUnCollapsedPickerIndex != 3;
            self.OOOCellToPicker.hidden = currentUnCollapsedPickerIndex != 5;
            
            [self.tableView reloadDataAnimated:YES];
        }
        else if (indexPath.row == 6)
        {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (void)updateTableView
{
    self.absenceHolidayCell.accessoryType = UITableViewCellAccessoryNone;
    self.OOOCell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (currentRequest)
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
            
            [self.tableView reloadDataAnimated:YES];
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
            
            [self.tableView reloadDataAnimated:YES];
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
            return 44;
        }
            break;
            
        case 1:
        {
            if (currentRequest == RequestTypeAbsenceHoliday)
            {
                return 22;
            }
        }
            break;
            
        case 2:
        {
            if (currentRequest == RequestTypeOutOfOffice)
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
            return 22;
        }
            break;
            
        case 1:
        {
            if (currentRequest == RequestTypeAbsenceHoliday)
            {
                return 22;
            }
        }
            break;
            
        case 2:
        {
            if (currentRequest == RequestTypeOutOfOffice)
            {
                return 22;
            }
        }
            break;
    }
    
    return 0.01;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
        {
            return @"REQUEST FOR";
        }
            break;
            
        case 1:
        {
            if (currentRequest == RequestTypeAbsenceHoliday)
            {
                return @"ABSENCE / HOLIDAY";
            }
        }
            break;
            
        case 2:
        {
            if (currentRequest == RequestTypeOutOfOffice)
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
            if ([sender.date compare:[NSDate date]] == NSOrderedAscending)
            {
                [sender setDate:[NSDate date] animated:YES];
            }
            
            self.absenceHolidayCellStart.detailTextLabel.text = [dateFormater stringFromDate:sender.date];
            
            if ([self.absenceHolidayEndPicker.date compare:self.absenceHolidayStartPicker.date] ==  NSOrderedAscending)
            {
                [self.absenceHolidayEndPicker setDate:self.absenceHolidayStartPicker.date animated:YES];
                self.absenceHolidayCellEnd.detailTextLabel.text = [dateFormater stringFromDate:sender.date];
            }
        }
            break;
            
        case DateTimeTypeAbsenceHolidayEnd:
        {
            if ([self.absenceHolidayEndPicker.date compare:self.absenceHolidayStartPicker.date] ==  NSOrderedAscending)
            {
                [self.absenceHolidayEndPicker setDate:self.absenceHolidayStartPicker.date animated:YES];
            }
            
            self.absenceHolidayCellEnd.detailTextLabel.text = [dateFormater stringFromDate:sender.date];
        }
            break;
            
            /////////////////////////////////////////////////////////////////////
            
        case DateTimeTypeOOODate:
        {
            if ([sender.date compare:[NSDate date]] == NSOrderedAscending)
            {
                [sender setDate:[NSDate date] animated:YES];
            }
            
            self.OOOCellDate.detailTextLabel.text = [dateFormater stringFromDate:sender.date];
        }
            break;
            
        case DateTimeTypeOOOFrom:
        {
            self.OOOCellFrom.detailTextLabel.text = [dateFormater stringFromDate:sender.date];
            
            if ([self.OOOToPicker.date compare:self.OOOFromPicker.date] ==  NSOrderedAscending)
            {
                [self.OOOToPicker setDate:self.OOOFromPicker.date animated:YES];
                self.OOOCellTo.detailTextLabel.text = [dateFormater stringFromDate:sender.date];
            }
        }
            break;
            
        case DateTimeTypeOOOTo:
        {
            if ([self.OOOToPicker.date compare:self.OOOFromPicker.date] ==  NSOrderedAscending)
            {
                [self.OOOToPicker setDate:self.OOOFromPicker.date animated:YES];
            }
            
            self.OOOCellTo.detailTextLabel.text = [dateFormater stringFromDate:sender.date];
        }
            break;
    }
    
    [self.tableView reloadDataAnimated:YES];
}

@end
