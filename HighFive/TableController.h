//
//  TableController.h
//  HighFive
//
//  Created by Trevor Grayson on 1/5/15.
//  Copyright (c) 2015 Ipsum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlapMotionWorker.h"

@interface TableController : UITableViewController<UITableViewDelegate, UIScrollViewDelegate>

@property(nonatomic, strong) NSString *headline;

@end
