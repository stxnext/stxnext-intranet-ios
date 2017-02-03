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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close)];
    [backButton setTintColor:[UIColor whiteColor]];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationItem setTitle:NSLocalizedString(@"Hours summary", nil)];
    
    CGRect calendarFrame = self.view.bounds;
    CGFloat calendarUnitHeight = (self.quarterMode) ? calendarFrame.size.height - 64.0 : 300.0;
    calendarFrame.origin.x = calendarFrame.size.width * 0.05;
    calendarFrame.size.width *= 0.9;
    calendarFrame.size.height = calendarUnitHeight;
    
    //setup the calendar
    FSCalendar* calendar = [[FSCalendar alloc] initWithFrame:calendarFrame];
    calendar.backgroundColor = [UIColor whiteColor];
    calendar.dataSource = self;
    calendar.delegate = self;
    calendar.allowsMultipleSelection = true;
    
    //set the weak pointer and appearance
    self.calendar = calendar;
    [self setCalendarAppearance];
    
    //set free days, these will be displayed in light gray
    for (NSDictionary *dict in self.hoursData) {
        BOOL isWorkingDay = [[dict objectForKey:@"is_working_day"] boolValue];
        if(!isWorkingDay) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            [calendar selectDate:[NSDate localDateFromDate:[dateFormatter dateFromString:[dict objectForKey:@"date"]]]];
        }
    }
    
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
    self.calendar.appearance.selectionColor = [Branding stxLightGray];
    self.calendar.appearance.cellShape = FSCalendarCellShapeRectangle;
    self.calendar.appearance.todayColor = [Branding stxGreen];
    self.calendar.appearance.eventColor = [UIColor redColor];
    self.calendar.appearance.titleSelectionColor = self.calendar.appearance.titleDefaultColor;
    self.calendar.appearance.subtitleSelectionColor = self.calendar.appearance.subtitleDefaultColor;
    self.calendar.firstWeekday = 2;
    self.calendar.appearance.headerDateFormat = @"MMM yyyy";
}

- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dictionaryKey = [formatter stringFromDate:date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", dictionaryKey];
    NSArray *results = [self.hoursData filteredArrayUsingPredicate:predicate];
    
    if(results.count > 0) {
        NSNumber *workedHours = [[results firstObject] objectForKey:@"time"];
        if(workedHours && ![workedHours isKindOfClass:[NSNull class]]) {
            return [NSString stringWithFormat:@"%.02f",[workedHours floatValue]];
        }
    }
    return @"";
}

// let's mark late entries as 'events' (red dot on the bottom of the cell)
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *dictionaryKey = [formatter stringFromDate:date];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date == %@", dictionaryKey];
    NSArray *results = [self.hoursData filteredArrayUsingPredicate:predicate];
    
    if(results.count > 0) {
        NSNumber *lateEntry = [[results firstObject] objectForKey:@"late_entry"];
        if(lateEntry && ![lateEntry isKindOfClass:[NSNull class]]) {
            return [lateEntry boolValue];
        }
    }
    return NO;
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    if(self.quarterMode) return [NSDate firstDayOfCurrentQuarter];
    return [NSDate firstDayOfCurrentMonth];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
    if(self.quarterMode) return [NSDate lastDayOfCurrentQuarter];
    return [NSDate lastDayOfCurrentMonth];
}

- (void)close {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
