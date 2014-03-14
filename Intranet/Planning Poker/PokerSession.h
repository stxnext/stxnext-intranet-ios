//
//  PokerSession.h
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PokerSession : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;

@property (nonatomic, copy) NSString *cardValuesTitle;
@property (nonatomic, strong) NSArray *cardValues;

@property (nonatomic, copy) NSString *teamTitle;
@property (nonatomic, strong) NSArray *teamUsersIDs;
@property (nonatomic, strong) NSNumber *teamID;

@property (nonatomic, strong) NSMutableArray *tickets;

@property (nonatomic, strong) NSDate *date;

@end
