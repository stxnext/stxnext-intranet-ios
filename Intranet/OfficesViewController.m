//
//  OfficesViewController.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 31.08.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "OfficesViewController.h"
#import "OfficeAnnotation.h"

#define MILES_TO_METERS 1609.344

@interface OfficesViewController ()

@end

@implementation OfficesViewController
{
    NSArray *officeLocations;
    NSUInteger currentOffice;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareButtons];
    
    [self.mapView addGestureRecognizer:self.swipeRightRecognizer];
    [self.mapView addGestureRecognizer:self.swipeLeftRecognizer];
    [self.navigationItem setTitle:NSLocalizedString(@"Offices", nil)];
    
    [self.cityLabel setTextColor:[Branding stxGreen]];
    [self.detailsLabel setTextColor:[Branding stxDarkGreen]];
    
    [self.infoWrapper setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.9]];
    [self prepareLocations];
}

- (void)prepareButtons {
    for (UIButton *btn in self.actionButtons) {
        [btn setTintColor:[Branding stxGray]];
        [btn setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.9]];
    }
}

- (void)prepareLocations {
    currentOffice = 0;
    NSDictionary *officePoznan = @{ kOFFICE_CITY : @"Poznań",
                                    kOFFICE_STREET : @"ul. Morawskiego 12/5",
                                    kOFFICE_POSTCODE : @"61-648",
                                    kOFFICE_PHONE : @"+48 61 610 01 92",
                                    kOFFICE_FAX : @"+48 61 610 03 18",
                                    kOFFICE_LATITUDE : @(52.394683),
                                    kOFFICE_LONGITUDE : @(16.894067) };
    NSDictionary *officePila = @{ kOFFICE_CITY : @"Piła",
                                  kOFFICE_STREET : @"al. Piastów 3",
                                  kOFFICE_POSTCODE : @"64-920",
                                  kOFFICE_PHONE : @"+48 67 342 32 16",
                                  kOFFICE_LATITUDE : @(53.148584),
                                  kOFFICE_LONGITUDE : @(16.738079) };
    NSDictionary *officeWroclaw = @{ kOFFICE_CITY : @"Wrocław",
                                     kOFFICE_STREET : @"ul. Aleksandra Hercena 3-5",
                                     kOFFICE_POSTCODE : @"50-316",
                                     kOFFICE_PHONE : @"+48 71 707 11 13",
                                     kOFFICE_LATITUDE : @(51.102992),
                                     kOFFICE_LONGITUDE : @(17.041462) };
    
    officeLocations = [NSArray arrayWithObjects:officePoznan, officePila, officeWroclaw, nil];
    [self setLocation:currentOffice withAnimation:NO];
}

- (void)setLocation:(NSUInteger)locationIndex withAnimation:(BOOL)animated {
    [_mapView removeAnnotations:[_mapView annotations]];
    NSDictionary *location = [officeLocations objectAtIndex:locationIndex];
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [[location objectForKey:@"Latitude"] doubleValue];
    zoomLocation.longitude = [[location objectForKey:@"Longitude"] doubleValue];
    
    OfficeAnnotation *annotation = [[OfficeAnnotation alloc] initWithData:location];
    [_mapView addAnnotation:annotation];

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*MILES_TO_METERS, 0.5*MILES_TO_METERS);
    
    [self.cityLabel setText:[location objectForKey:kOFFICE_CITY]];
    NSMutableString *subtitleString = [[NSMutableString alloc] initWithFormat:@"%@\n",[location objectForKey:kOFFICE_STREET]];
    [subtitleString appendFormat:@"%@ %@\n\n",[location objectForKey:kOFFICE_POSTCODE], [location objectForKey:kOFFICE_CITY]];
    if([location objectForKey:kOFFICE_PHONE]) [subtitleString appendFormat:@"Tel.: %@\n", [location objectForKey:kOFFICE_PHONE]];
    if([location objectForKey:kOFFICE_FAX]) [subtitleString appendFormat:@"Fax: %@", [location objectForKey:kOFFICE_FAX]];
    [self.detailsLabel setText:[subtitleString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    
    [_mapView setRegion:viewRegion animated:animated];
    currentOffice = locationIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)swipeLocation:(id)sender {
    if([(UISwipeGestureRecognizer *)sender isEqual:self.swipeLeftRecognizer])
    {
        //go to previous office
        if(currentOffice == 0) [self setLocation:officeLocations.count-1 withAnimation:YES];
        else [self setLocation:currentOffice-1 withAnimation:YES];
    }
    else if([(UISwipeGestureRecognizer *)sender isEqual:self.swipeRightRecognizer])
    {
        //go to next office
        if(currentOffice == officeLocations.count-1) [self setLocation:0 withAnimation:YES];
        else [self setLocation:currentOffice+1 withAnimation:YES];
    }
}

#pragma mark annotation view

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    UIActionSheet *officeActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Call", nil), NSLocalizedString(@"Show on map", nil), NSLocalizedString(@"Navigate", nil), nil];
    if(INTERFACE_IS_PHONE) [officeActionSheet showFromTabBar:self.tabBarController.tabBar];
}

#pragma mark action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    OfficeAnnotation *pin = (OfficeAnnotation *)[self.mapView.annotations firstObject];
    [self.mapView deselectAnnotation:pin animated:NO];
    
    switch (buttonIndex) {
        case 0:
        {
            NSString *phoneNumber = [[pin.currentLocation objectForKey:kOFFICE_PHONE] stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", phoneNumber]];
            [[UIApplication sharedApplication] openURL:url];
            break;
        }
        case 1:
        {
            [pin.office openInMapsWithLaunchOptions:nil];
            break;
        }
        case 2:
        {
            NSDictionary *navigation = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
            [pin.office openInMapsWithLaunchOptions:navigation];
            break;
        }
        default:
            break;
    }
}

- (IBAction)triggerAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSUInteger selectedAction = 0;
    
    if([btn isEqual:self.locationButton]) selectedAction = 1;
    else if([btn isEqual:self.navigationButton]) selectedAction = 2;
    
    [self actionSheet:nil clickedButtonAtIndex:selectedAction];
}

#pragma mark mapkit

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self performMapHotfix];
}

- (void)performMapHotfix //based on stackoverflow question id 12641658
{
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.mapType = MKMapTypeStandard;
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
