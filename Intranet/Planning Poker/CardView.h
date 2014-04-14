//
//  WidgetView.h
//  CompositeXibPart1
//
//  Created by Paul on 8/22/13.
//  Copyright (c) 2013 Paul Solt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardView : UIView
{
    IBOutlet UIView* _mainContainerView;
    IBOutlet UIView* _backgroundContainerView;
    IBOutlet UIImageView* _backgroundView;
    IBOutlet UILabel* _largeValueLabel;
    IBOutlet UILabel* _smallBottomValueLabel;
}

@property (nonatomic, strong) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *cardNumbersCollection;

- (void)setCardNumbersValue:(NSString *)value;

@end
