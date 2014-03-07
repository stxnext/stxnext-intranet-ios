//
//  PFRound.h
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFRound : PFObject<PFSubclassing>

@property (nonatomic, strong) NSNumber* index;
@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSNumber* timeout;

@property (nonatomic, strong) NSArray* votes;

@end
