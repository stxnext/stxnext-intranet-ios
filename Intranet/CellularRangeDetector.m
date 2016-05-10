//
//  CellularRangeDetector.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 13.10.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import "CellularRangeDetector.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation CellularRangeDetector

//based on stackoverflow solution @ http://stackoverflow.com/a/27922674
+ (BOOL)hasCellularCoverage {
    CTTelephonyNetworkInfo *networkInfo = [CTTelephonyNetworkInfo new];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    if (!carrier.isoCountryCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *noRangeAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No range", nil) message:NSLocalizedString(@"No cellular coverage.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [noRangeAlert show];
        });
        return NO;
    }
    return YES;
}

@end
