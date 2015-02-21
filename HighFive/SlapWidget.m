//
//  SlapWidget.m
//  HighFive
//
//  Created by Trevor Grayson on 2/20/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import "SlapWidget.h"

@interface SlapWidget ()

@end

@implementation SlapWidget

@synthesize score;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    [mainBundle loadNibNamed: @"SlapWidget" owner:self options:nil];
    self.view.frame = frame;
    self.bounds = self.view.bounds;
    
    [self addSubview: self.view];
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [UIView transitionWithView: self duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{ self.alpha = 0.0; } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
