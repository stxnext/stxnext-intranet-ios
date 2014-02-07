//
//  WidgetView.h
//  CompositeXibPart1
//
//  Created by Paul on 8/22/13.
//  Copyright (c) 2013 Paul Solt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardView : UIView

@property (nonatomic, strong) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *cardNumbersCollection;

- (void)setCardNumbersValue:(NSString *)value;

@end
