//
//  GridViewController.h
//  BoardInterface
//
//  Created by Maciej Chmielewski on 14.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GridEntity.h"

@interface GridView : NSView

- (void)addEntity:(GridEntity *)entity;
- (void)deleteEntity:(GridEntity *)entity;

@end
