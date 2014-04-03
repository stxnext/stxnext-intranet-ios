//
//  UITableSection.h
//  Intranet
//
//  Created by Dawid Żakowski on 31/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITableSection : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic) NSInteger tag;
@property (nonatomic, strong) NSArray* rows;

+ (instancetype)sectionWithName:(NSString*)name withTag:(NSInteger)tag withRows:(NSArray*)rows;
+ (NSArray*)sectionsWithoutEmpty:(NSArray*)sections;
+ (UITableSection*)sectionAtIndexPath:(NSIndexPath*)indexPath inSectionsArray:(NSArray*)sections;
+ (id)rowAtIndexPath:(NSIndexPath*)indexPath inSectionsArray:(NSArray*)sections;
- (void)deleteRowAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface UITableTextRow : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* value;

+ (instancetype)rowWithName:(NSString*)name withValue:(NSString*)value;

@end

@interface UITableView (SectionHeaderButton)

- (void)rebuildSectionHeaderButtonWithTitle:(NSString*)buttonTitle
                              forHeaderView:(UIView*)view
                                  inSection:(NSInteger)section
                           withTouchHandler:(void (^)())touchBlock;

@end

@interface UITableView (AnimatedReload)

- (void)reloadAllRowsWithRowAnimation:(UITableViewRowAnimation)rowAnimation;

@end