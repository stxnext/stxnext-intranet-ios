//
//  UIColor+Version.h
//

#import <UIKit/UIKit.h>

@interface UIDevice (Version)

+ (NSString *)machineName;
+ (NSString *)systemVersion;

+ (BOOL)isPad;
+ (BOOL)isPhone;

@end
