//
//  PGEstimationResultsViewController.h
//  Intranet
//
//  Created by Dawid Żakowski on 08/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBBaseChartViewController.h"

@interface PGEstimationResultsViewController : JBBaseChartViewController
{
    BOOL _isEstimationFinished;
    NSMutableDictionary* _barsCache;
}

@end

@interface PGEstimationResultsChartBar : UIView
{
    CGRect _newFrame;
    BOOL _isAnimating;
}

@end