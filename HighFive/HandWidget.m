//
//  HandWidget.m
//  HighFive
//
//  Created by Trevor Grayson on 7/28/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "HandWidget.h"

@implementation HandWidget

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

- (id) initWithCount:(NSInteger) count andFrame:(CGRect)frame
{
    self = [self initWithFrame:frame];
    if (self) {
        UILabel *cLbl = [[UILabel alloc] init];
        cLbl.text = [NSString stringWithFormat:@"%d", count];
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
@end
