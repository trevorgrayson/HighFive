//
//  HandWidget.h
//  HighFive
//
//  Created by Trevor Grayson on 7/28/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface HandWidget : UIImageView

- (id) initWithCount:(int) count andFrame:(CGRect)frame;

@property int count;
@property double maxSlapFerocity;

@property (nonatomic, weak) User *user;
@end
