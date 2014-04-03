//
//  UITableSection.m
//  Intranet
//
//  Created by Dawid Żakowski on 31/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "UITableSection.h"

@implementation UITableSection

+ (instancetype)sectionWithName:(NSString*)name withTag:(NSInteger)tag withRows:(NSArray*)rows;
{
    UITableSection* section = [UITableSection new];
    section.name = name;
    section.tag = tag;
    section.rows = rows;
    
    return section;
}

+ (NSArray*)sectionsWithoutEmpty:(NSArray*)sections
{
    return [sections filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"rows != nil && rows[SIZE] > 0"]];
}

+ (UITableSection*)sectionAtIndexPath:(NSIndexPath*)indexPath inSectionsArray:(NSArray*)sections
{
    UITableSection* section = sections[indexPath.section];
    return section;
}

+ (id)rowAtIndexPath:(NSIndexPath*)indexPath inSectionsArray:(NSArray*)sections
{
    UITableSection* section = [UITableSection sectionAtIndexPath:indexPath inSectionsArray:sections];
    return section.rows[indexPath.row];
}

- (void)deleteRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSMutableArray* newRows = self.rows.mutableCopy;
    [newRows removeObjectAtIndex:indexPath.row];
    self.rows = newRows;
}

@end

@implementation UITableTextRow

+ (instancetype)rowWithName:(NSString*)name withValue:(NSString*)value
{
    UITableTextRow* row = [UITableTextRow new];
    row.name = name;
    row.value = value;
    
    return row;
}

@end

@implementation UITableView (SectionHeaderButton)

- (void)rebuildSectionHeaderButtonWithTitle:(NSString*)buttonTitle
                              forHeaderView:(UIView*)view
                                  inSection:(NSInteger)section
                           withTouchHandler:(void (^)())touchBlock
{
    [view performBlockOnAllSubviews:^(UIView *view) {
        if ([view isKindOfClass:[UITableViewHeaderFooterView class]])
        {
            UITableViewHeaderFooterView* header = (UITableViewHeaderFooterView*)view;
            __block UIButton* sectionButton = nil;
            
            [header performBlockOnAllSubviews:^(UIView *view) {
                if ([view isKindOfClass:[UIButton class]])
                    sectionButton = (UIButton*)view;
            }];
            
            if (!sectionButton)
            {
                sectionButton = [UIButton buttonWithType:UIButtonTypeSystem];
                [sectionButton setTitle:buttonTitle forState:UIControlStateNormal];
                
                CGSize textSize = [sectionButton.titleLabel sizeThatFits:CGSizeZero];
                
                sectionButton.frame = CGRectMake(header.contentView.bounds.size.width - textSize.width - 14,
                                                 header.contentView.bounds.size.height - sectionButton.titleLabel.bounds.size.height - 6,
                                                 textSize.width,
                                                 sectionButton.titleLabel.bounds.size.height);
                
                [header.contentView addSubview:sectionButton];
            }
            
            [sectionButton bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
            [sectionButton bk_addEventHandler:^(id sender) {
                touchBlock();
            } forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

@end

@implementation UITableView (AnimatedReload)

// Reloads cell views for all rows excluding section related views like header and footer
- (void)reloadAllRowsWithRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSMutableArray* indexPathes = [NSMutableArray array];
    
    NSInteger sectionCount = [self.dataSource numberOfSectionsInTableView:self];
    
    for (NSInteger sectionIndex = 0; sectionIndex < sectionCount; sectionIndex++)
    {
        NSInteger rowCount = [self.dataSource tableView:self numberOfRowsInSection:sectionIndex];
        
        for (NSInteger rowIndex = 0; rowIndex < rowCount; rowIndex++)
        {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            [indexPathes addObject:indexPath];
        }
    }
    
    [self reloadRowsAtIndexPaths:indexPathes withRowAnimation:rowAnimation];
}

@end