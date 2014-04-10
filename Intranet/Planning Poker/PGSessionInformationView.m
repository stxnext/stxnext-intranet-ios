//
//  PGSessionInformationView.m
//  Intranet
//
//  Created by Adam on 08.04.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGSessionInformationView.h"


@interface PGSessionInformationView ()
{
    NSMutableArray *subViews;
}

@end

@implementation PGSessionInformationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.bouncesZoom = NO;
        self.showsHorizontalScrollIndicator = self.showsVerticalScrollIndicator = NO;
        self.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        self.pagingEnabled = YES;
        self.contentOffset = CGPointZero;
        self.clipsToBounds = YES;
        
        subViews = [NSMutableArray new];
    }
    
    return self;
}
#define padding 2
- (void)setPlayers:(NSArray *)players
{
    [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [subViews removeAllObjects];
    
    int i = 0;
    
    for (GMUser *player in players)
    {
        UIImageView *photoView = [[UIImageView alloc] initWithFrame:CGRectMake(i * 80 + padding,
                                                                               0 + padding,
                                                                               80 - 2 * padding,
                                                                               80 - 2 * padding)];
        
        photoView.layer.cornerRadius =  MIN(photoView.frame.size.width, photoView.frame.size.height) / 2.0;
        photoView.layer.masksToBounds = YES;
        photoView.layer.borderColor = [UIColor whiteColor].CGColor;
        photoView.layer.borderWidth = 0.25;
        photoView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        photoView.layer.shouldRasterize = YES;

        [photoView setImageUsingCookiesWithURL:[[HTTPClient sharedClient].baseURL URLByAppendingPathComponent:player.imageURL]];

        photoView.layer.shadowOpacity = 0.8;
        photoView.layer.shadowRadius = 2.0;
        photoView.layer.shadowOffset = CGSizeMake(0.7, 0.7);
        photoView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        photoView.layer.shouldRasterize = YES;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * 80 + padding,
                                                                       80,
                                                                       80 - 2 * padding,
                                                                       20)];
        
        nameLabel.layer.shadowOpacity = 1.0;
        nameLabel.layer.shadowRadius = 1.0;
        nameLabel.layer.shadowOffset = CGSizeMake(0.7, 0.7);
        nameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        nameLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        nameLabel.layer.shouldRasterize = YES;
        
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:9];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.text = [player name];
        
        [self addSubview:photoView];
        [self addSubview:nameLabel];

        [subViews addObject:photoView];
        [subViews addObject:nameLabel];
        
        i++;
    }
    
    self.contentInset = UIEdgeInsetsZero;
    self.contentSize = CGSizeMake(players.count * 80, CGRectGetHeight(self.bounds));
}

@end
