//
//  UIView+Blocks.h
//

#import <UIKit/UIKit.h>

typedef void (^SubviewBlock) (UIView* view);
typedef void (^SuperviewBlock) (UIView* superview);

@interface UIView (Blocks)

- (void)performBlockOnAllSubviews:(SubviewBlock)block;
- (void)performBlockOnAllSuperviews:(SuperviewBlock)block;

@end
