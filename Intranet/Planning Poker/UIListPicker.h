//
//  UIListPicker.h
//  Intranet
//
//  Created by Dawid Żakowski on 31/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIListPicker : UIPickerView<UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSString* (^_nameBlock)(id element);
    void (^_selectionChangeBlock)(UIListPicker* picker, id selectedElement);
}

@property (nonatomic, strong, readonly) NSArray* list;
@property (nonatomic, strong, readonly) id selectedElement;

- (void)setPickerElementsList:(NSArray*)list
          withSelectedElement:(id)selectedElement
        withElementNameMapper:(NSString* (^)(id element))nameBlock
   withSelectionChangeHandler:(void (^)(UIListPicker* picker, id selectedElement))selectionChangeBlock;

@end