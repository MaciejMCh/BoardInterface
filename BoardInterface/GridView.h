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

@property (nonatomic, copy, nonnull) GridEntity * _Nonnull (^blankGridFactory)(void);

- (void)addEntity:(GridEntity * _Nonnull)entity;
- (void)deleteEntity:(GridEntity * _Nonnull)entity;
- (void)replaceEntity:(GridEntity * _Nonnull)oldEntity withEntity:(GridEntity * _Nonnull)newEntity;

@end
