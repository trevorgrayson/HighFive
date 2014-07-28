//
//  ViewController.h
//  HighFive
//
//  Created by Trevor Grayson on 7/18/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AddressBookUI/AddressBookUI.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MessageUI/MessageUI.h>
#import "Slapperometer.h"
#import "SlapNet.h"
#import "HandWidget.h"

double currentMaxAccelX;
double currentMaxAccelY;
double currentMaxAccelZ;

int uiMode;

@interface ViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate, MFMessageComposeViewControllerDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    UITextFieldDelegate>

@property (strong, nonatomic) CMMotionManager *motionManager;

@property (strong, nonatomic) NSString *targetAddress;

@property (weak, nonatomic) IBOutlet UILabel *slapDebug;
@property (weak, nonatomic) IBOutlet UILabel *fiveCompanion;
@property (weak, nonatomic) IBOutlet UITextField *textArea;

@property (weak, nonatomic) IBOutlet UIButton *resetBtn;

@property (weak, nonatomic) IBOutlet UIImageView *hand;

@property (strong, nonatomic) IBOutlet UIImagePickerController *imagePicker;

- (void) receiveHighFive:(double) ferocity from:(NSString*) contact as:(NSString*) name;
- (void) slapModeFor:(NSString*) name at:(NSString*) phone with:(double) ferocity;

- (void) waitingMode;
//- (void) slapMode;
@end
