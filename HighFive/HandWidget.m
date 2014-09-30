//
//  HandWidget.m
//  HighFive
//
//  Created by Trevor Grayson on 7/28/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "HandWidget.h"

@implementation HandWidget

@synthesize count;
@synthesize user;
@synthesize maxSlapFerocity;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [UIImage imageNamed:@"internet-high-five.jpeg"];
        self.backgroundColor = [UIColor greenColor];
        //self.frame = CGRectMake(0, 0, 50, 50);
        
    }
    return self;
}

- (id) initWithCount:(int) c
{
    count = c;
    
    self = [self initWithFrame: CGRectMake(0, 0, 50, 50)];

    if (self) {
        UILabel *cLbl = [[UILabel alloc] init];

        cLbl.backgroundColor = [UIColor clearColor];
        cLbl.frame = CGRectMake(3,
                                10,
                                self.frame.size.width,
                                self.frame.size.height);
        cLbl.textAlignment = NSTextAlignmentCenter;
        [self addSubview: cLbl];
        
    }
    return self;
}

- (void) setNum:(int) c {
    count = c;
    UILabel *label = [self.subviews objectAtIndex: 0];
    label.text = [user initials];
    [label setNeedsDisplay];
}

- (void) addFerocity: (double) ferocity {
    maxSlapFerocity = fmax(maxSlapFerocity, ferocity);
}

- (void) addSlap: (Slap*) slap {
    user = slap.slapper;
    maxSlapFerocity = fmax(maxSlapFerocity, slap.ferocity);
}

@end
