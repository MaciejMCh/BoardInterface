//
//  SliderView.m
//  BoardInterface
//
//  Created by Maciej Chmielewski on 15.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "SliderView.h"

@implementation SliderView

- (void)applyUnfocusedStyle {
    self.layer.borderWidth = 0;
}

- (void)applyFocusedStyle {
    self.layer.borderWidth = 15;
    self.layer.borderColor = [NSColor greenColor].CGColor;
}

- (void)applyEditingStyle {
    self.layer.borderWidth = 15;
    self.layer.borderColor = [NSColor orangeColor].CGColor;
}

@end
