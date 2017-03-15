//
//  SliderView.h
//  BoardInterface
//
//  Created by Maciej Chmielewski on 15.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SliderView : NSView

@property (nonatomic, weak) IBOutlet NSTextField *nameLabel;
@property (nonatomic, weak) IBOutlet NSTextField *valueLabel;

- (void)applyFocusedStyle;
- (void)applyUnfocusedStyle;
- (void)applyEditingStyle;

@end
