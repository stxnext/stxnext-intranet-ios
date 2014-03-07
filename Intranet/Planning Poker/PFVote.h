//
//  PFVote.h
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFVote : PFObject<PFSubclassing>

@property (nonatomic, strong) NSNumber* value;
@property (nonatomic, strong) PFUser* author;

@end
