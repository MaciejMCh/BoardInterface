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
@property (nonatomic, strong) GridEntity *draggingEntity;
@property (nonatomic, strong) NSView *draggingShadowView;
@property (nonatomic, strong) NSMutableArray<GridEntity *> *entities;
@property (nonatomic, assign) CGSize itemSize;

@end

@implementation GridView

- (void)setInteraction:(Interaction)interaction {
    NSLog(@"%d -> %d", _interaction, interaction);
    _interaction = interaction;
}

- (void)addEntity:(GridEntity *)entity {
    [self.entities addObject:entity];
    [self addSubview:entity.view];
    [self resizeSubviewsWithOldSize:[self dirtyRect].size];
    NSLog(@"ADD");
}

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
    
    self.entities = [NSMutableArray new];
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    self.itemSize = CGSizeMake(CGRectGetWidth([self dirtyRect]) / [self numberOfCollumns], CGRectGetHeight([self dirtyRect]) / [self numberOfRows]);
    ;
    [self layoutGrid];
}

- (void)updateInteraction {
    for (GridEntity *entity in self.entities) {
        entity.view.layer.backgroundColor = [NSColor redColor].CGColor;
        if (self.interaction == Focusing) {
            if (CGRectContainsPoint(entity.view.frame, [self inViewSpace:self.focusingTouch])) {
                entity.view.layer.backgroundColor = [NSColor greenColor].CGColor;
            }
        }
    }
    if (self.interaction == Dragging) {
        self.draggingEntity.view.layer.backgroundColor = [NSColor orangeColor].CGColor;
    }
}

- (void)layoutGrid {
    for (int i = 0; i < [self numberOfItems]; i++) {
        CGRect rect = [self frameForItemAtIndex:i];
        self.entities[i].view.frame = rect;
    }
}

- (CGRect)frameForItemAtIndex:(int)index {
    int i = 0;
    for (int y = 0; y < [self numberOfRows]; y++) {
        for (int x = 0; x < [self numberOfCollumns]; x++) {
            if (i == index) {
                return CGRectMake(self.itemSize.width * x,
                                  CGRectGetHeight([self dirtyRect]) - self.itemSize.height * (y + 1),
                                  self.itemSize.width,
                                  self.itemSize.height);
            }
            i ++;
        }
    }
    return CGRectZero;
}

- (void)beginDragging {
    for (GridEntity *entity in self.entities) {
        if (CGRectContainsPoint(entity.view.frame, [self inViewSpace:self.doubleOnTouch])) {
            [self setupDraggingShadowView];
            self.draggingEntity = entity;
            return;
        }
    }
    self.interaction = None;
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
    
    int previousIndex = [self.entities indexOfObject:self.draggingEntity];
    [self.entities removeObject:self.draggingEntity];
    for (int i = 0; i < [self numberOfItems]; i++) {
        if (CGRectContainsPoint([self frameForItemAtIndex:i], self.viewSpaceDraggingPoint)) {
            [self.entities insertObject:self.draggingEntity atIndex:i];
            [self layoutGrid];
            return;
        }
    }
    
    [self.entities insertObject:self.draggingEntity atIndex:previousIndex];
    [self layoutGrid];
}

- (CGFloat)padding {
    return 10;
}

- (int)numberOfItems {
    return self.entities.count;
}

- (int)numberOfRows {
    if ([self numberOfItems] == 1) {
        return 1;
    }
    if ([self numberOfItems] == 2) {
        return 1;
    }
    if ([self numberOfItems] > 2) {
        return 2;
    }
    
    return 0;
}

- (int)numberOfCollumns {
    if ([self numberOfItems] == 1) {
        return 1;
    }
    if ([self numberOfItems] == 2) {
        return 2;
    }
    if ([self numberOfItems] > 2) {
        return (int)ceil((float)[self numberOfItems] / 2.0);
    }
    
    return 0;
}

- (CGFloat)minX:(NSEvent *)event {
    CGFloat x = CGFLOAT_MAX;
    for (NSTouch *touch in [event touchesMatchingPhase:NSTouchPhaseTouching inView:self]) {
        x = MIN(x, touch.normalizedPosition.x);
    }
    return x;
}

- (void)touchesBeganWithEvent:(NSEvent *)event {
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 1) {
        self.interaction = Focusing;
        self.focusingTouch = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self].allObjects.firstObject;
        [self updateInteraction];
    }
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 2) {
        if ([self minX:event] < 0.01) {
            GridEntity *newEntity = [GridEntity blank];
            [self addEntity:newEntity];
            self.interaction = Dragging;
            self.draggingEntity = newEntity;
            [self setupDraggingShadowView];
            
            return;
        }
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
