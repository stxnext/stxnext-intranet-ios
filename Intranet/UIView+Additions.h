//
//  UIView+Additions.h
//  PeoPay
//
//  Created by Adam on 23.01.2014.
//  Copyright (c) 2014 Softax. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SubviewBlock) (UIView* view);
typedef void (^SuperviewBlock) (UIView* superview);

@interface UIView (Additions)

- (void)logViewHierarchy;

- (void)performBlockOnAllSubviews:(SubviewBlock)block;
- (void)performBlockOnAllSuperviews:(SuperviewBlock)block;

@end
