//
//  HandWidget.h
//  HighFive
//
//  Created by Trevor Grayson on 7/28/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Slap.h"

@interface HandWidget : UIImageView

- (id) initWithCount:(int) count;

@property int count;
@property double maxSlapFerocity;

@property (nonatomic, strong) User *user;

- (void) setNum:(int) c;
- (void) addSlap: (Slap*) slap;
- (void) addFerocity: (double) ferocity;
@end
