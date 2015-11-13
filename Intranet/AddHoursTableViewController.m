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
    
    [self.submitButton setEnabled:NO];
    selectedProject = [self.projectsList firstObject];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)checkFormStatus {
    if(!selectedProject || [self.ticketDuration.text isNilOrEmpty] || [self.ticketDescription.text isNilOrEmpty]) [self.submitButton setEnabled:NO];
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
    if(![self.ticketIdentifier.text isNilOrEmpty]) [parameters setObject:self.ticketIdentifier.text forKey:@"ticket_id"];
    
    [[HTTPClient sharedClient] startOperation:[APIRequest addHours:[parameters copy]] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"An error occurred. Please try again later.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }];
}

@end
