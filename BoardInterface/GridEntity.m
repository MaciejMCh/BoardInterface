//
//  GridEntity.m
//  BoardInterface
//
//  Created by Maciej Chmielewski on 15.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "GridEntity.h"

@implementation GridEntity

+ (GridEntity *)blank {
    GridEntity *gridEntity = [GridEntity new];
    NSView *view = [NSView new];
    view.wantsLayer = YES;
    view.layer.borderColor = [NSColor blackColor].CGColor;
    view.layer.borderWidth = 2;
    gridEntity.view = view;
    gridEntity.model = @"blank";
    return gridEntity;
}

@end
