//
//  GridViewController.m
//  BoardInterface
//
//  Created by Maciej Chmielewski on 14.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "GridViewController.h"


typedef NS_ENUM(NSUInteger, Interaction) {
    None,
    Focusing,
    DoubleOn,
    Dragging
};


@interface GridView ()

@property (nonatomic, assign) Interaction interaction;
@property (nonatomic, strong) NSTouch *focusingTouch;
@property (nonatomic, assign) NSPoint viewSpaceDraggingPoint;
@property (nonatomic, strong) NSTouch *doubleOnTouch;
@property (nonatomic, strong) NSView *draggingView;
@property (nonatomic, strong) NSView *draggingShadowView;
@property (nonatomic, strong) NSMutableArray<NSView *> *views;
@property (nonatomic, assign) CGSize itemSize;

@end

@implementation GridView

- (CGRect)dirtyRect {
    return self.bounds;
}

- (CGPoint)inViewSpace:(NSTouch *)touch {
    return CGPointMake(CGRectGetWidth([self dirtyRect]) * touch.normalizedPosition.x,
                       CGRectGetHeight([self dirtyRect]) * touch.normalizedPosition.y);
}

- (void)awakeFromNib {
    [self setAcceptsTouchEvents:YES];
    [self setWantsRestingTouches:YES];
    self.interaction = None;
    
    self.views = [NSMutableArray new];
    for (int i = 0; i < [self numberOfItems]; i++) {
        NSView *view = [NSView new];
        view.wantsLayer = YES;
        view.layer.backgroundColor = [NSColor redColor].CGColor;
        view.layer.borderColor = [NSColor blackColor].CGColor;
        view.layer.borderWidth = 2;
        
        NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        textField.stringValue = [NSString stringWithFormat:@"%d", i];
        [view addSubview:textField];
        
        [self addSubview:view];
        [self.views addObject:view];
    }
    
    [self layoutGrid];
    [self updateInteraction];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    self.itemSize = CGSizeMake(CGRectGetWidth([self dirtyRect]) / [self numberOfCollumns], CGRectGetHeight([self dirtyRect]) / [self numberOfRows]);
    ;
    [self layoutGrid];
}

- (void)updateInteraction {
    for (NSView *view in self.views) {
        view.layer.backgroundColor = [NSColor redColor].CGColor;
        if (self.interaction == Focusing) {
            if (CGRectContainsPoint(view.frame, [self inViewSpace:self.focusingTouch])) {
                view.layer.backgroundColor = [NSColor greenColor].CGColor;
            }
        }
    }
    if (self.interaction == Dragging) {
        self.draggingView.layer.backgroundColor = [NSColor orangeColor].CGColor;
    }
}

- (void)layoutGrid {
    for (int i = 0; i < [self numberOfItems]; i++) {
        CGRect rect = [self frameForItemAtIndex:i];
        self.views[i].frame = rect;
    }
}

- (CGRect)frameForItemAtIndex:(int)index {
    int i = 0;
    for (int x = 0; x < [self numberOfRows]; x++) {
        for (int y = 0; y < [self numberOfRows]; y++) {
            if (i == index) {
                return CGRectMake(self.itemSize.width * x,
                                  self.itemSize.height * y,
                                  self.itemSize.width,
                                  self.itemSize.height);
            }
            i ++;
        }
    }
    return CGRectZero;
}

- (void)beginDragging {
    [self setupDraggingShadowView];
    for (NSView *view in self.views) {
        if (CGRectContainsPoint(view.frame, [self inViewSpace:self.doubleOnTouch])) {
            self.draggingView = view;
            return;
        }
    }
}

- (void)setupDraggingShadowView {
    self.draggingShadowView = [NSView new];
    self.draggingShadowView.wantsLayer = YES;
    self.draggingShadowView.layer.backgroundColor = [NSColor colorWithWhite:1 alpha:0.3].CGColor;
    [self addSubview:self.draggingShadowView];
}

- (void)updateDragging {
    self.draggingShadowView.frame = CGRectMake(self.viewSpaceDraggingPoint.x - self.itemSize.width / 2,
                                               self.viewSpaceDraggingPoint.y - self.itemSize.height / 2,
                                               self.itemSize.width,
                                               self.itemSize.height);
    
    int previousIndex = [self.views indexOfObject:self.draggingView];
    [self.views removeObject:self.draggingView];
    for (int i = 0; i < [self numberOfItems]; i++) {
        if (CGRectContainsPoint([self frameForItemAtIndex:i], self.viewSpaceDraggingPoint)) {
            [self.views insertObject:self.draggingView atIndex:i];
            [self layoutGrid];
            return;
        }
    }
    
    [self.views insertObject:self.draggingView atIndex:previousIndex];
    [self layoutGrid];
}

- (CGFloat)padding {
    return 10;
}

- (int)numberOfItems {
    return 4;
}

- (int)numberOfRows {
    return 2;
}

- (int)numberOfCollumns {
    return 2;
}

- (void)touchesBeganWithEvent:(NSEvent *)event {
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 1) {
        self.interaction = Focusing;
        self.focusingTouch = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self].allObjects.firstObject;
        [self updateInteraction];
    }
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 2) {
        self.interaction = DoubleOn;
        self.doubleOnTouch = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self].allObjects.firstObject;
        [self updateInteraction];
    }
}

- (void)touchesMovedWithEvent:(NSEvent *)event {
    if (self.interaction == Focusing) {
        self.focusingTouch = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self].allObjects.firstObject;
        [self updateInteraction];
    }
    if (self.interaction == DoubleOn) {
        self.interaction = Dragging;
        [self beginDragging];
    }
    if (self.interaction == Dragging) {
        CGFloat x = CGFLOAT_MAX;
        CGFloat y = CGFLOAT_MAX;
        for (NSTouch *touch in [event touchesMatchingPhase:NSTouchPhaseTouching inView:self]) {
            x = MIN(x, touch.normalizedPosition.x);
            y = MIN(y, touch.normalizedPosition.y);
        }
        self.viewSpaceDraggingPoint = CGPointMake(x * CGRectGetWidth([self dirtyRect]), y * CGRectGetHeight([self dirtyRect]));
        [self updateDragging];
        [self updateInteraction];
    }
}

- (void)touchesEndedWithEvent:(NSEvent *)event {
    [self.draggingShadowView removeFromSuperview];
    self.draggingShadowView = nil;
    
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 0) {
        self.interaction = None;
        [self updateInteraction];
    }
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 1) {
        self.interaction = Focusing;
        self.focusingTouch = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self].allObjects.firstObject;
        [self updateInteraction];
    }
}

- (void)touchesCancelledWithEvent:(NSEvent *)event {
    [self touchesEndedWithEvent:event];
}

@end
