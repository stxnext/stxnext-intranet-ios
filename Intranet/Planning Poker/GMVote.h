//
//  GMVote.h
//  Intranet
//
//  Created by Dawid Żakowski on 24/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "GMModel.h"

@interface GMVote : GMModel

extern NSString* const kGMVoteIdentifier;
extern NSString* const kGMVoteCard;
extern NSString* const kGMVotePlayer;
extern NSString* const kGMVoteTicketIdentifier;

@property (nonatomic, strong) NSNumber* identifier;
@property (nonatomic, strong) GMCard* card;
@property (nonatomic, strong) GMUser* player;
@property (nonatomic, strong) NSNumber* ticketIdentifier;

@end
