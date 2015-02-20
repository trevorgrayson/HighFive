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
    [mainBundle loadNibNamed: @"SlapWid" owner:self options:nil];
    self.view.frame = frame;
    self.bounds = self.view.bounds;
    
    UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch:)];
    [self.view addGestureRecognizer:touch];
    [self addSubview: self.view];
    
    return self;
}

- (void) touch:(id) sender {
    [self removeFromSuperview];
}
@end
