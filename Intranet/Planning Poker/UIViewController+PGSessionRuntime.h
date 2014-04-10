//
//  UIViewController+PGSessionRuntime.h
//  Intranet
//
//  Created by Dawid Żakowski on 09/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+QuickObservers.h"

@interface UIViewController (PGSessionRuntime)

- (BOOL)popToViewControllerOfClass:(Class)class;
- (void)prepareForGameSession;
- (IBAction)showParticipants:(id)sender;

@end
