//
//  CarousellView.m
//  BoardInterface
//
//  Created by Maciej Chmielewski on 14.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "CarousellView.h"

@interface CarousellView ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSView *> *nodeViewsByIndex;

@end

@implementation CarousellView

- (NSMutableDictionary<NSNumber *,NSView *> *)nodeViewsByIndex {
    if (!_nodeViewsByIndex) {
        _nodeViewsByIndex = [NSMutableDictionary new];
    }
    return _nodeViewsByIndex;
}

- (int)nodesCount {
    return 3;
}

- (CGSize)sizeOfItem {
    return CGSizeMake(100, 100);
}

- (NSView *)createNodeView {
    NSView *view = [NSView new];
    
    view.wantsLayer = YES;
    view.layer.backgroundColor = [NSColor redColor].CGColor;
    view.layer.cornerRadius = [self sizeOfItem].width / 2;
    view.layer.masksToBounds = YES;
    
    return view;
}

- (void)createNodeViews {
    for (int i = 0; i < [self nodesCount]; i ++) {
        NSNumber *key = [NSNumber numberWithInt:i];
        if (![self.nodeViewsByIndex objectForKey:key]) {
            NSView *newNodeView = [self createNodeView];
            [self.nodeViewsByIndex setObject:newNodeView forKey:key];
            [self addSubview:newNodeView];
        }
    }
}

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    [super resizeSubviewsWithOldSize:oldSize];
    [self updateLayout];
}

- (void)updateLayout {
    [self createNodeViews];
    CGFloat radius = MIN(
                         CGRectGetHeight(self.bounds) - ([self sizeOfItem].height),
                         CGRectGetWidth(self.bounds) - ([self sizeOfItem].width))
    / 2.0;
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0);
    [self.nodeViewsByIndex enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSView * _Nonnull nodeView, BOOL * _Nonnull stop) {
        float angle = (float)M_PI * 2.0 / (float)[self nodesCount] * [key floatValue];
        angle += M_PI_2;
        CGRect frame = CGRectMake(center.x + (cos(angle) * radius), center.y + (sin(angle) * radius), 100, 100);
        frame.origin.x -= [self sizeOfItem].height / 2.0;
        frame.origin.y -= [self sizeOfItem].width / 2.0;
        nodeView.frame = frame;
    }];
}

@end
