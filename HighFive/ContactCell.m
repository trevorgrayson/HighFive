//
//  ContactCell.m
//  HighFive
//
//  Created by Trevor Grayson on 1/5/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import "ContactCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ContactCell
@synthesize icon;

- (void)awakeFromNib {
    // Initialization code
    self.icon.clipsToBounds = YES;
    self.icon.layer.cornerRadius = self.icon.layer.bounds.size.width / 2;
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
