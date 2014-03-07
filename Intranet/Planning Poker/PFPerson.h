//
//  PFPerson.h
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFPerson : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSNumber* revision;

@end
