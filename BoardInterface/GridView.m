//
//  GridViewController.m
//  BoardInterface
//
//  Created by Maciej Chmielewski on 14.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "GridView.h"

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

#pragma mark -
#pragma mark - Accessors

- (NSMutableArray<GridEntity *> *)entities {
    if (!_entities) {
        _entities = [NSMutableArray new];
    }
    return _entities;
}

#pragma mark -
#pragma mark - Dev

- (void)setInteraction:(Interaction)interaction {
    NSLog(@"%d -> %d", _interaction, interaction);
    _interaction = interaction;
}

#pragma mark -
#pragma mark - Interface

- (void)addEntity:(GridEntity *)entity {
    [self.entities addObject:entity];
    [self addSubview:entity.view];
    [self resizeSubviewsWithOldSize:[self dirtyRect].size];
    [self updateInteraction];
}

- (void)deleteEntity:(GridEntity *)entity {
    [self.entities removeObject:entity];
    [entity.view removeFromSuperview];
    [self resizeSubviewsWithOldSize:[self dirtyRect].size];
    [self updateInteraction];
}

#pragma mark - 
#pragma mark - System callbacks

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setAcceptsTouchEvents:YES];
    [self setWantsRestingTouches:YES];
    self.interaction = None;
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    self.itemSize = CGSizeMake(CGRectGetWidth([self dirtyRect]) / [self numberOfCollumns], CGRectGetHeight([self dirtyRect]) / [self numberOfRows]);
    ;
    [self layoutGrid];
}

#pragma mark -
#pragma mark - Layouting math

- (CGFloat)minX:(NSEvent *)event {
    CGFloat x = CGFLOAT_MAX;
    for (NSTouch *touch in [event touchesMatchingPhase:NSTouchPhaseTouching inView:self]) {
        x = MIN(x, touch.normalizedPosition.x);
    }
    return x;
}

- (CGFloat)maxX:(NSSet<NSTouch *> *)touches {
    CGFloat x = 0;
    for (NSTouch *touch in touches) {
        x = MAX(x, touch.normalizedPosition.x);
    }
    return x;
}

- (CGFloat)padding {
    return 10;
}

- (CGFloat)normalizedMarginSize {
    return 0.05;
}

- (int)numberOfItems {
    return (int)self.entities.count;
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

- (CGRect)dirtyRect {
    return self.bounds;
}

- (CGPoint)inViewSpace:(NSTouch *)touch {
    return CGPointMake(CGRectGetWidth([self dirtyRect]) * touch.normalizedPosition.x,
                       CGRectGetHeight([self dirtyRect]) * touch.normalizedPosition.y);
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

#pragma mark - 
#pragma mark - Appearence

- (void)updateInteraction {
    for (GridEntity *entity in self.entities) {
        entity.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
        if (self.interaction == Focusing) {
            if (CGRectContainsPoint(entity.view.frame, [self inViewSpace:self.focusingTouch])) {
                entity.view.layer.backgroundColor = [NSColor greenColor].CGColor;
            }
        }
        if (self.interaction == Dragging) {
            if (CGRectContainsPoint(entity.view.frame, self.viewSpaceDraggingPoint)) {
                entity.view.layer.backgroundColor = [[NSColor orangeColor] colorWithAlphaComponent:0.5].CGColor;
            }
        }
    }
    if (self.interaction == Dragging) {
        self.draggingEntity.view.layer.backgroundColor = [NSColor orangeColor].CGColor;
    }
}

#pragma mark -
#pragma mark - Action

- (void)performAction {
    for (GridEntity *entity in self.entities) {
        if (CGRectContainsPoint(entity.view.frame, [self inViewSpace:self.doubleOnTouch])) {
            entity.action();
        }
    }
}

#pragma mark -
#pragma mark - Dragging

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

- (void)updateDragging {
    self.draggingShadowView.frame = CGRectMake(self.viewSpaceDraggingPoint.x - self.itemSize.width / 2,
                                               self.viewSpaceDraggingPoint.y - self.itemSize.height / 2,
                                               self.itemSize.width,
                                               self.itemSize.height);
}

- (void)successDragging {
    [self.draggingShadowView removeFromSuperview];
    self.draggingShadowView = nil;
    
    int dragDestinationIndex;
    for (dragDestinationIndex = 0; dragDestinationIndex < [self numberOfItems]; dragDestinationIndex++) {
        CGRect rect = [self frameForItemAtIndex:dragDestinationIndex];
        if (CGRectContainsPoint(rect, self.viewSpaceDraggingPoint)) {
            break;
        }
    }
    
    if (dragDestinationIndex < [self numberOfItems]) {
        NSUInteger dragSourceIndex = [self.entities indexOfObject:self.draggingEntity];
        [self.entities exchangeObjectAtIndex:dragSourceIndex withObjectAtIndex:dragDestinationIndex];
        [self layoutGrid];
    }
}

- (void)cancelDragging {
    [self.draggingShadowView removeFromSuperview];
    self.draggingShadowView = nil;
}

- (void)setupDraggingShadowView {
    self.draggingShadowView = [NSView new];
    self.draggingShadowView.wantsLayer = YES;
    self.draggingShadowView.layer.backgroundColor = [NSColor colorWithWhite:1 alpha:0.3].CGColor;
    [self addSubview:self.draggingShadowView];
}

#pragma mark - 
#pragma mark - Touches

- (void)touchesBeganWithEvent:(NSEvent *)event {
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 1) {
        self.interaction = Focusing;
        self.focusingTouch = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self].allObjects.firstObject;
        [self updateInteraction];
    }
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 2) {
        if ([self minX:event] < [self normalizedMarginSize]) {
            GridEntity *newEntity = self.blankGridFactory();
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(endTouches:) withObject:event afterDelay:0.1];
}

- (void)endTouches:(NSEvent *)event {
    if (self.interaction == Dragging) {
        if ([self maxX:[event touchesMatchingPhase:NSTouchPhaseEnded inView:self]] + [self normalizedMarginSize] > 1) {
            self.interaction = None;
            [self.draggingShadowView removeFromSuperview];
            self.draggingShadowView = nil;
            [self deleteEntity:self.draggingEntity];
            return;
        }
    }
    
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 0) {
        if (self.interaction == Dragging) {
            [self successDragging];
        }
        if (self.interaction == DoubleOn) {
            [self performAction];
        }
        self.interaction = None;
        [self updateInteraction];
    }
    if ([event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count == 1) {
        if (self.interaction == Dragging) {
            [self cancelDragging];
        }
        self.interaction = Focusing;
        self.focusingTouch = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self].allObjects.firstObject;
        [self updateInteraction];
    }
}

- (void)touchesCancelledWithEvent:(NSEvent *)event {
    [self touchesEndedWithEvent:event];
}

@end
