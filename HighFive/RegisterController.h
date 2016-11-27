//
//  RegisterController.h
//  HighFive
//
//  Created by Trevor Grayson on 11/5/16.
//  Copyright © 2016 Ipsum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlapMotionWorker.h"
#import "AppDelegate.h"
#import "ReachUp.h"

@interface RegisterController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *mobileField;
@property (weak, nonatomic) IBOutlet UILabel *commandText;

@end
