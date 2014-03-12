//
//  CardsTypeTableViewController.h
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextInputViewController.h"

#define FibonaciTitle @"Fibonaci"
#define FibonaciValues @"0, 1, 2, 3, 5, 8, 13, 20, 40, 100, ?, cafe"

#define BinaryTitle @"Binary"
#define BinaryValues @"0, 1, 2, 4, 8, 16, 32, 64, 128, ?, cafe"

#define LargeTitle @"Large"
#define LargeValues @"0, 10, 20, 30, 50, 80, 130, 200, 400, 999, ?, cafe"

#define OneToTenTitle @"1 to 10"
#define OneToTenValues @"1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ?, cafe"

#define CustomTitle @"Custom"

@protocol CardsTypeTableViewControllerDelegate;
@interface CardsTypeTableViewController : UITableViewController <TextInputViewControllerDelegate>

@property (strong, nonatomic) id<CardsTypeTableViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString *selectedCardsValuesTitle;
@property (nonatomic, copy) NSString *customCardValues;


- (NSString *)customCardValues;
- (void)setCustomCardValues:(NSString *)values;

@end

@protocol CardsTypeTableViewControllerDelegate <NSObject>

- (void)cardsTypeTableViewController:(CardsTypeTableViewController *)cardsTypeTableViewController
             didFinishWithValues:(NSArray *)values
                     cardsValuesTitle:(NSString *)title;

@end
