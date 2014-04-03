//
//  UIListPicker.m
//  Intranet
//
//  Created by Dawid Żakowski on 31/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "UIListPicker.h"

@implementation UIListPicker

#pragma mark Init

- (void)constructor
{
    self.delegate = self;
    self.dataSource = self;
}

- (id)init
{
    self = [super init];
    
    if (self)
        [self constructor];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
        [self constructor];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
        [self constructor];
    
    return self;
}

#pragma mark Public methods

- (void)setPickerElementsList:(NSArray*)list
          withSelectedElement:(id)selectedElement
        withElementNameMapper:(NSString* (^)(id element))nameBlock
   withSelectionChangeHandler:(void (^)(UIListPicker* picker, id selectedElement))selectionChangeBlock
{
    _list = list;
    _selectedElement = selectedElement;
    _nameBlock = nameBlock;
    _selectionChangeBlock = selectionChangeBlock;
    
    [self reloadAllComponents];
}

#pragma mark - Delegate and data source

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _list.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _nameBlock(_list[row]);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _selectedElement = _list[row];
    
    if (_selectionChangeBlock)
        _selectionChangeBlock(self, _selectedElement);
}

@end