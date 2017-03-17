//
//  Slider.m
//  BoardInterface
//
//  Created by Maciej Chmielewski on 15.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "Slider.h"

@implementation Slider

- (instancetype)initWithName:(NSString *)name
                      values:(NSArray<NSString *> *)values
               selectedIndex:(int)selectedIndex
                 valueUpdate:(void (^)(Slider *slider))valueUpdate {
    self = [super init];
    self.name = name;
    self.values = values;
    self.selectedIndex = selectedIndex;
    self.valueUpdate = valueUpdate;
    return self;
}

- (void)setSelectedIndex:(int)selectedIndex {
    _selectedIndex = selectedIndex % self.values.count;
}

- (NSString *)selectedValue {
    return self.values[self.selectedIndex];
}

@end
