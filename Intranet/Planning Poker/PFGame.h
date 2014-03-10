//
//  PFGame.h
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum PokerDeckType {
    PokerDeckFibonacci = 0,
    PokerDeckCount,
} PokerDeckType;

@interface PFGame : PFObject<PFSubclassing>

@property (nonatomic, strong) NSDate* startDate;
@property (nonatomic, strong) NSDate* endDate;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) PFUser* owner;
@property (nonatomic, strong) NSNumber* deck;

@property (nonatomic, strong) NSArray* players;
@property (nonatomic, strong) NSArray* tickets;

@end
