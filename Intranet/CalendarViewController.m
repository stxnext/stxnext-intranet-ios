//
//  CalendarViewController.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 18.11.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import "CalendarViewController.h"
#import "NSDate+TimePeriods.h"
#import "FSCalendar.h"

@interface CalendarViewController () <FSCalendarDataSource, FSCalendarDelegate>

@property (weak, nonatomic) FSCalendar *calendar;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(close)];
    [backButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    CGFloat calendarUnitHeight = (self.quarterMode) ? 600.0 : 300.0;
    CGRect calendarFrame = self.view.bounds;
    calendarFrame.size.height = calendarUnitHeight;
    
    //setup the calendar
    FSCalendar* calendar = [[FSCalendar alloc] initWithFrame:calendarFrame];
    calendar.dataSource = self;
    calendar.delegate = self;
    
    //set the weak pointer and appearance
    self.calendar = calendar;
    [self setCalendarAppearance];
    
    //set selected dates, these will be displayed in red
    NSDate *selectionDate = [calendar dateByAddingDays:-2 toDate:[NSDate date]];
    [calendar selectDate:selectionDate];
    
    //disable date selection, we don't want to select them manually
    calendar.allowsSelection = false;
    calendar.allowsMultipleSelection = false;
    
    [self.view addSubview:calendar];
    // Do any additional setup after loading the view.
}

- (void)setCalendarAppearance {
    self.calendar.pagingEnabled = false;
    self.calendar.appearance.headerTitleColor = [Branding stxDarkGreen];
    self.calendar.appearance.weekdayTextColor = [Branding stxGreen];
    self.calendar.appearance.selectionColor = [UIColor redColor];
    self.calendar.appearance.cellShape = FSCalendarCellShapeRectangle;
    self.calendar.appearance.todayColor = [Branding stxGreen];
    self.calendar.firstWeekday = 2;
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    if(self.quarterMode) return [NSDate firstDayOfCurrentQuarter];
    return [NSDate firstDayOfCurrentMonth];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
    if(self.quarterMode) return [NSDate lastDayOfCurrentQuarter];
    return [NSDate lastDayOfCurrentMonth];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close {
    [self dismissViewControllerAnimated:self.navigationController completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
