//
//  OfficeAnnotation.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 31.08.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import "OfficeAnnotation.h"

@implementation OfficeAnnotation

- (id)initWithData:(NSDictionary *)officeData {
    if(self == [super init]) {
        self.currentLocation = officeData;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D location;
    location.latitude = [[self.currentLocation objectForKey:kOFFICE_LATITUDE] doubleValue];
    location.longitude = [[self.currentLocation objectForKey:kOFFICE_LONGITUDE] doubleValue];
    
    return location;
}

- (MKMapItem *)office {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:self.currentLocation];
    MKMapItem *item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = [self.currentLocation objectForKey:kOFFICE_CITY];
    
    return item;
}

@end
