//
//  PGPlayerPickerViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 31/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PGPlayerPickerViewController;

@protocol PGPlayerPickerViewControllerDelegate <NSObject>

- (void)playerPickerViewController:(PGPlayerPickerViewController*)playerPickerViewController
              didFinishWithPlayers:(NSSet*)players;

@end

typedef enum PlayerFilter {
    PlayerFilterOwnTeams = 0,
    PlayerFilterAllTeams,
    PlayerFiltersCount
} PlayerFilter;

@interface PGPlayerPickerViewController : UITableViewController
{
    NSArray* _tableSections;
    PlayerFilter _tableFilter;
}

@property (strong, nonatomic) id<PGPlayerPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSSet* selectedPlayers;

@end