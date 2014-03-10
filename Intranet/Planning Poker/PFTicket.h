//
//  PFTicket.h
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFTicket : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* description;
@property (nonatomic, strong) NSNumber* finalEstimate;
@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSDate* endDate;

@property (nonatomic, strong) NSArray* rounds;

@end
