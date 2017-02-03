//
//  AddHoursTableViewController.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 13.11.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import "AddHoursTableViewController.h"
#import "NSString+IsNilOrEmpty.h"
#import "APIRequest.h"

@interface AddHoursTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *ticketDuration;
@property (weak, nonatomic) IBOutlet UIPickerView *projectPicker;
@property (weak, nonatomic) IBOutlet UITextField *ticketIdentifier;
@property (weak, nonatomic) IBOutlet UITextField *ticketDescription;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;

@end

@implementation AddHoursTableViewController
{
    NSDictionary *selectedProject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDelegatesAndObservers];
    [self.navigationItem setTitle:NSLocalizedString(@"Add hours", nil)];
    
    [self.submitButton setEnabled:NO];
    selectedProject = [self.projectsList firstObject];
    
    [self.ticketIdentifier setPlaceholder:NSLocalizedString(@"Ticket identifier", nil)];
    [self.ticketDescription setPlaceholder:NSLocalizedString(@"Ticket description", nil)];
    [self.ticketDuration setPlaceholder:NSLocalizedString(@"Time as float value", nil)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setDelegatesAndObservers {
    self.projectPicker.delegate = self;
    self.projectPicker.dataSource = self;
    
    self.ticketDescription.delegate = self;
    self.ticketDuration.delegate = self;
    self.ticketIdentifier.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkFormStatus) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedProject = [self.projectsList objectAtIndex:row];
    [self checkFormStatus];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[self.projectsList objectAtIndex:row] objectForKey:@"name"];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.projectsList count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *decimalSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    if([textField isEqual:self.ticketDuration] || [textField isEqual:self.ticketIdentifier]) {
        if (![[NSNumberFormatter new] numberFromString:string] && ![string isEqualToString:@""] && ![string isEqualToString:decimalSeparator]) return NO;
        if ([textField isEqual:self.ticketIdentifier] && [string isEqualToString:decimalSeparator]) return NO;
        NSInteger points = [[textField.text componentsSeparatedByString:decimalSeparator] count] - 1;
        if(points > 0 && [string isEqualToString:decimalSeparator]) return NO;
    }
    return YES;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *textLabel = (id)view;
    
    if (!textLabel) {
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [pickerView rowSizeForComponent:component].width, [pickerView rowSizeForComponent:component].height)];
    }
    
    [textLabel setText:[self pickerView:pickerView titleForRow:row forComponent:component]];
    [textLabel setFont:[UIFont systemFontOfSize:22.0f]];
    [textLabel setTextAlignment:NSTextAlignmentCenter];
    return textLabel;
}

- (void)checkFormStatus {
    if(!selectedProject || [NSString isNilOrEmpty:self.ticketDuration.text] || [NSString isNilOrEmpty:self.ticketDescription.text]) [self.submitButton setEnabled:NO];
    else [self.submitButton setEnabled:YES];
}

- (IBAction)cancelForm:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitForm:(id)sender {
    NSString *decimalSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleDecimalSeparator];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Warsaw"]];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{ @"project_id" : [selectedProject objectForKey:@"id"], @"time" : [[NSString stringWithFormat:@"%0.2f",[[[NSNumberFormatter new] numberFromString:self.ticketDuration.text] floatValue]] stringByReplacingOccurrencesOfString:decimalSeparator withString:@"."], @"description" : self.ticketDescription.text, @"date" : dateString}];
    if([NSString isNilOrEmpty:self.ticketIdentifier.text]) [parameters setObject:self.ticketIdentifier.text forKey:@"ticket_id"];
    
    [[HTTPClient sharedClient] startOperation:[APIRequest addHours:[parameters copy]] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kHOURSADDED object:nil];
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occurred. Please try again later.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return NSLocalizedString(@"Time entry", nil);
            break;
        case 1:
            return NSLocalizedString(@"Project", nil);
            break;
        case 2:
            return NSLocalizedString(@"Description", nil);
            break;
        default:
            return @"";
            break;
    }
}

@end
