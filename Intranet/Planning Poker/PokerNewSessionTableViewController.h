//
//  NewPokerSessionTableViewController.h
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PokerSession.h"
#import "TextInputViewController.h"
#import "CardsTypeTableViewController.h"
#import "TeamsTableViewController.h"

typedef NS_ENUM(NSUInteger, PokerSessionType)
{
    PokerSessionTypeQuick,
    PokerSessionTypeNormal
};

@interface PokerNewSessionTableViewController : UITableViewController <TextInputViewControllerDelegate, CardsTypeTableViewControllerDelegate>
{
    
}

@property (nonatomic, strong) NSMutableArray *ticketList;
@property (nonatomic, assign) PokerSessionType pokerSessionType;
@property (nonatomic, strong) PokerSession *pokerSession;

@end
