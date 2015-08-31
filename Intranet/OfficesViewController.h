//
//  OfficesViewController.h
//  Intranet
//
//  Created by Paweł Urbanowicz on 31.08.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface OfficesViewController : UIViewController <UIGestureRecognizerDelegate, MKMapViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRightRecognizer;
@property (weak, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeLeftRecognizer;

#pragma mark office details
@property (weak, nonatomic) IBOutlet UIView *infoWrapper;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@end
