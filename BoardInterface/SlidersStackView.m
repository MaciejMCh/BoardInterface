//
//  SlidersStackView.m
//  BoardInterface
//
//  Created by Maciej Chmielewski on 15.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "SlidersStackView.h"
#import "SliderView.h"

@interface SlidersStackView ()

@property (nonatomic, assign) CGPoint doubleOnNormalizedPosition;
@property (nonatomic, strong) NSMutableArray<SliderView *> *sliderViews;
@property (nonatomic, assign) float lastTickPosition;
@property (nonatomic, strong) Slider *editingSlider;

@end

@implementation SlidersStackView

#pragma mark -
#pragma mark - Accessors

- (NSMutableArray<SliderView *> *)sliderViews {
    if (!_sliderViews) {
        _sliderViews = [NSMutableArray new];
    }
    return _sliderViews;
}

- (void)setSliders:(NSArray<Slider *> *)sliders {
    _sliders = sliders;
    
    for (Slider *slider in self.sliders) {
        SliderView *sliderView = [self createSldierView:slider];
        sliderView.nameLabel.stringValue = slider.name;
        sliderView.valueLabel.stringValue = slider.selectedValue;
        [self addSubview:sliderView];
        [self.sliderViews addObject:sliderView];
    }
    [self resizeSubviewsWithOldSize:[self dirtyRect].size];
}

- (CGFloat)normalizedSpaceValueTick {
    return 0.1;
}

#pragma mark -
#pragma mark - System callbacks

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setAcceptsTouchEvents:YES];
    [self setWantsRestingTouches:YES];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    CGRect dirtyRect = self.bounds;
    CGFloat singleSliderWidth = CGRectGetWidth(dirtyRect) / self.sliderViews.count;
    
    for (int i = 0; i < self.sliderViews.count; i++) {
        self.sliderViews[i].frame = CGRectMake(singleSliderWidth * i, 0, singleSliderWidth, CGRectGetHeight(dirtyRect));
    }
}

#pragma mark -
#pragma mark - Utilities

- (CGRect)dirtyRect {
    return self.bounds;
}

- (SliderView *)createSldierView:(Slider *)slider {
    NSArray *nibContents;
    [[NSBundle bundleForClass:[Slider class]] loadNibNamed:@"Slider" owner:nil topLevelObjects:&nibContents];
    for (id element in nibContents) {
        if ([element isKindOfClass:[SliderView class]]) {
            [element setWantsLayer:YES];
            return element;
        }
    }
    return nil;
}

- (CGPoint)inViewSpace:(NSTouch *)touch {
    return CGPointMake(CGRectGetWidth([self dirtyRect]) * touch.normalizedPosition.x,
                       CGRectGetHeight([self dirtyRect]) * touch.normalizedPosition.y);
}

- (CGPoint)toViewSpace:(CGPoint)normalizedSpacePoint {
    return CGPointMake(CGRectGetWidth([self dirtyRect]) * normalizedSpacePoint.x,
                       CGRectGetHeight([self dirtyRect]) * normalizedSpacePoint.y);
}

- (CGPoint)normalizedSpaceTouchingPoint:(NSEvent *)event {
    CGFloat x = 0;
    CGFloat y = 0;
    for (NSTouch *touch in [event touchesMatchingPhase:NSTouchPhaseTouching inView:self]) {
        x += touch.normalizedPosition.x;
        y += touch.normalizedPosition.y;
    }
    x /= [event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count;
    y /= [event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count;
    
    return CGPointMake(x, y);
}

#pragma mark -
#pragma mark - Appearence

- (void)updateAppearence:(NSEvent *)event {
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 0) {
        for (SliderView *sliderView in self.sliderViews) {
            [sliderView applyUnfocusedStyle];
        }
    }
    
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 1) {
        for (SliderView *sliderView in self.sliderViews) {
            if (CGRectContainsPoint(sliderView.frame, [self inViewSpace:[event touchesMatchingPhase:NSTouchPhaseTouching inView:self].allObjects.firstObject])) {
                [sliderView applyFocusedStyle];
            } else {
                [sliderView applyUnfocusedStyle];
            }
        }
    }
    
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count >= 2) {
        for (SliderView *sliderView in self.sliderViews) {
            if (CGRectContainsPoint(sliderView.frame, [self toViewSpace:self.doubleOnNormalizedPosition])) {
                self.editingSlider = self.sliders[[self.sliderViews indexOfObject:sliderView]];
                [sliderView applyEditingStyle];
            }
        }
    }
}

#pragma mark -
#pragma mark - Touches

- (void)touchesBeganWithEvent:(NSEvent *)event {
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count >= 2) {
        self.doubleOnNormalizedPosition = [self normalizedSpaceTouchingPoint:event];
        self.lastTickPosition = self.doubleOnNormalizedPosition.y;
    }
    
    [self updateAppearence:event];
}

- (void)touchesMovedWithEvent:(NSEvent *)event {
    [self updateAppearence:event];
    
    int touchesCount = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count;
    if (touchesCount >= 2) {
        CGPoint normalizedSpaceTouchingPoint = [self normalizedSpaceTouchingPoint:event];
        float normalizedDifference = normalizedSpaceTouchingPoint.y - self.lastTickPosition;
        if (fabs(normalizedDifference) > [self normalizedSpaceValueTick]) {
            int value = touchesCount == 2 ? 1 : 10;
            if (normalizedDifference < 0) {
                value *= -1;
            }
            [self valueChanged:value];
            self.lastTickPosition = normalizedSpaceTouchingPoint.y;
        }
    }
}

- (void)valueChanged:(int)steps {
    self.editingSlider.selectedIndex += steps;
    self.editingSlider.valueUpdate(self.editingSlider);
    
    SliderView *editingSliderView = self.sliderViews[[self.sliders indexOfObject:self.editingSlider]];
    editingSliderView.valueLabel.stringValue = [self.editingSlider selectedValue];
}

- (void)touchesEndedWithEvent:(NSEvent *)event {
    [self updateAppearence:event];
}

- (void)touchesCancelledWithEvent:(NSEvent *)event {
    [self touchesEndedWithEvent:event];
}

@end
