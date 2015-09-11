//
//  MainVerticalTabBarViewController.m
//  Intranet
//
//  Created by Tomasz Walenciak on 04.09.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "MainVerticalTabBarViewController.h"


#import "AddOOOFormTableViewController.h"
#import "SettingsTableViewController.h"
#import "LatenessViewController.h"

#import "TabIconTableViewCell.h"

#import "UIImage+Color.h"

@interface MainVerticalTabBarViewController ()<UIGestureRecognizerDelegate, AddOOOFormTableViewControllerDelegate, LatenessViewControllerDelegate>//<UIActionSheetDelegate>

@property (nonatomic) NSArray *modelImagesData;
@property (nonatomic) NSUInteger selectedRow;

@end


@implementation MainVerticalTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.verticalBarTableView.dataSource = self;
    self.verticalBarTableView.delegate = self;
    
    _modelImagesData = @[
                         @"employee1", //
                         @"office-worker2",
                         @"businessman243",
                         @"office17",
                         @"businessman267", // 4 - lateness
                         @"wallclock", // absence
                         @"travel25", // holiday
                         @"three115",
                         ];
    
    NSIndexPath *initialSelected = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.verticalBarTableView selectRowAtIndexPath:initialSelected
                                           animated:NO
                                     scrollPosition:UITableViewScrollPositionNone];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UITapGestureRecognizer *tapBehindGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBehindDetected:)];
    [tapBehindGesture setNumberOfTapsRequired:1];
    tapBehindGesture.cancelsTouchesInView = NO;
    tapBehindGesture.delegate = self;
    
    [self.view.window addGestureRecognizer:tapBehindGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [self.view.window removeGestureRecognizer:_tapBehindGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableView Delegate/Data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.modelImagesData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TabIconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tab_cell" forIndexPath:indexPath];
    
    NSString *imgName = _modelImagesData[indexPath.row];
    
    UIImage *imageInCell = [UIImage imageNamed:imgName];
    
    cell.tabImageView.image = [[imageInCell imagePaintedWithColor:[Branding stxLightGreen]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.selected = indexPath.row == _selectedRow;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >3) {
        UIViewController *modalController;
        
        if (indexPath.row == 4) {
            LatenessViewController *latenessContr = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil]instantiateViewControllerWithIdentifier:@"LatenessFormId"];
            latenessContr.delegate = self;
            modalController = latenessContr;
        }
        
        if (indexPath.row == 5 || indexPath.row == 6) {
            // absence/holiday
            AddOOOFormTableViewController *rootHolidayContr = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil]instantiateViewControllerWithIdentifier:@"HolidayAbsenceControllerId"];
            
            RequestType reqType = RequestTypeOutOfOffice;
            if (indexPath.row == 6) {
                reqType = RequestTypeAbsenceHoliday;
            }
            rootHolidayContr.currentRequest = reqType;
            rootHolidayContr.delegate = self;
            
            modalController = rootHolidayContr;
        }
        
        if (indexPath.row == 7) {
            SettingsTableViewController *settingsContr = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil]instantiateViewControllerWithIdentifier:@"SettingsFormId"];
            
            modalController = settingsContr;
        }
        
        if (modalController) {
            modalController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:modalController
                               animated:YES completion:^{
                                   
                               }];
        } else {
            NSLog(@"nil view controller, not showing");
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 4) {
        _selectedRow = indexPath.row;
        self.embededTabBarController.selectedIndex = indexPath.row;
    } else {
        
    }
}

- (void)tapBehindDetected:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"touch");
        if (self.presentedViewController) {
            
            CGPoint locatView = [sender locationInView:self.view];
            NSLog(@"location in view %@", NSStringFromCGPoint(locatView));
            
            CGSize modalSize = self.presentedViewController.view.frame.size;
            CGSize viewSize = self.view.frame.size;
            CGFloat dx = (viewSize.width - modalSize.width) / 2.f;
            CGFloat dy = (viewSize.height - modalSize.height) / 2.f;
            CGRect rectModal = CGRectInset(self.view.frame, dx, dy);
            
            if (!CGRectContainsPoint(rectModal, locatView)) {
            
                [self dismissFormController];
            }
        }
    }
}

- (void)didFinishLatenessProcess
{
    [self dismissFormController];
}

- (void)didFinishAddingOOO
{
    [self dismissFormController];
}

- (void)dismissFormController
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSIndexPath *prevIP = [NSIndexPath indexPathForRow:_selectedRow inSection:0];
    [self.verticalBarTableView selectRowAtIndexPath:prevIP animated:NO scrollPosition:UITableViewScrollPositionNone];
    
}

//
#pragma mark - Gesture Recognizer
// because of iOS8

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"content_embed_segue"]) {
        self.embededTabBarController = segue.destinationViewController;
    }
}

@end
