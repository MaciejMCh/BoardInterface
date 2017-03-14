//
//  ViewController.m
//  BoardInterface
//
//  Created by Maciej Chmielewski on 14.03.2017.
//  Copyright © 2017 Maciej Chmielewski. All rights reserved.
//

#import "ViewController.h"
#import "CarousellView.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [((CarousellView *)self.view) updateLayout];
}

@end
