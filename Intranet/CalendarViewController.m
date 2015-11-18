//
//  CalendarViewController.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 18.11.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import "CalendarViewController.h"
#import "FSCalendar.h"

@interface CalendarViewController () <FSCalendarDataSource, FSCalendarDelegate>

@property (weak, nonatomic) FSCalendar *calendar;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect calendarFrame = self.view.bounds;
    calendarFrame.size.height -= self.navigationController.navigationBar.bounds.size.height;
    
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
    NSDate *quarterStart;
    [[NSCalendar currentCalendar] rangeOfUnit: NSCalendarUnitQuarter
                                    startDate: &quarterStart
                                     interval: nil
                                      forDate: [self localDateFromDate:[NSDate date]]];
    
    return [self localDateFromDate:quarterStart];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
    NSDateComponents* components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[self localDateFromDate:[NSDate date]]];
    NSUInteger quarter = (components.month - 1) / 3 + 1;
    NSUInteger lastQuarterMonth = quarter * 3;
    NSUInteger nextQuarterFirstMonth = lastQuarterMonth + 1;
    [components setMonth: nextQuarterFirstMonth];
    [components setDay: 0];
    
    return [self localDateFromDate:[[NSCalendar currentCalendar] dateFromComponents: components]];
}

- (NSDate *)localDateFromDate:(NSDate *)date
{
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    NSInteger interval = [timeZone secondsFromGMTForDate:date];
    return [NSDate dateWithTimeInterval:interval sinceDate:date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
