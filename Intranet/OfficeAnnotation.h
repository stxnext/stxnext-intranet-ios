//
//  OfficeAnnotation.h
//  Intranet
//
//  Created by Paweł Urbanowicz on 31.08.2015.
//  Copyright (c) 2015 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <MapKit/MapKit.h>

#define kOFFICE_CITY (__bridge NSString *)kABPersonAddressCityKey
#define kOFFICE_STREET (__bridge NSString *)kABPersonAddressStreetKey
#define kOFFICE_POSTCODE (__bridge NSString *)kABPersonAddressZIPKey
#define kOFFICE_PHONE (__bridge NSString *)kABPersonPhoneMainLabel
#define kOFFICE_FAX (__bridge NSString *)kABPersonPhoneHomeFAXLabel

#define kOFFICE_LATITUDE @"Latitude"
#define kOFFICE_LONGITUDE @"Longitude"

@interface OfficeAnnotation : NSObject <MKAnnotation>

@property NSDictionary *currentLocation;
- (id)initWithData:(NSDictionary *)officeData;
- (MKMapItem *)office;

@end
