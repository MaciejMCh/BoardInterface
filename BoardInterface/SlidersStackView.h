//
//  SlidersStackView.h
//  BoardInterface
//
//  Created by Maciej Chmielewski on 15.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Slider.h"

@interface SlidersStackView : NSView

@property (nonatomic, strong) NSArray<Slider *> *sliders;
@property (nonatomic, copy) void (^dismiss)(void);

@end
