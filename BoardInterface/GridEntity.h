//
//  GridEntity.h
//  BoardInterface
//
//  Created by Maciej Chmielewski on 15.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface GridEntity : NSObject

@property (nonatomic, strong) id model;
@property (nonatomic, strong) NSView *view;

+ (GridEntity *)blank;

@end
