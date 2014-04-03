//
//  PGSessionCreateViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 28/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextInputViewController.h"
#import "PGPlayerPickerViewController.h"

@interface PGSessionCreateViewController : UITableViewController<TextInputViewControllerDelegate, PGPlayerPickerViewControllerDelegate>
{
    BOOL _isDeckPickerVisible;
    BOOL _isDatePickerVisible;
}

@property (nonatomic, strong, readonly) GMSession* session;

@end