//
//  Slider.h
//  BoardInterface
//
//  Created by Maciej Chmielewski on 15.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Slider : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray<NSString *> *values;
@property (nonatomic, assign) int selectedIndex;

@property (nonatomic, copy) void (^valueUpdate)(void);

@end
