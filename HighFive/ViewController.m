//
//  ViewController.m
//  HighFive
//
//  Created by Trevor Grayson on 7/18/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize targetAddress;
@synthesize imagePicker;
@synthesize textArea;

//TODO ENUMs
int kWAITING_MODE =0;
int kSLAP_MODE = 1;

NSString *userName = nil;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reset:nil];
    [self waitingMode];
    targetAddress = @"";
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
        [self outputAccelertionData:accelerometerData.acceleration];
        
        if(error){ NSLog(@"%@", error); }
    }];
    //[self configureCamera];
    [self checkUserName];
    
    HandWidget *hw = [[HandWidget alloc] initWithCount: 5
                                              andFrame: CGRectMake(self.view.frame.origin.x + 2,
                                                                   self.view.frame.origin.y +
                                                                   self.view.frame.size.height - 50 - 2,
                                                                   50, 50)];
    [self.view addSubview: hw];
    //GYRO DATA
    //[self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
    //[self outputRotationData:gyroData.rotationRate]; }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTap:)];
    [self.hand addGestureRecognizer: tap];
}

- (void) receiveHighFive:(double) ferocity from:(NSString*) contact as:(NSString *)name
{
    [self slapModeFor: name at: contact with:ferocity];
}

//f(x)
-(void) checkUserName
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    userName = [prefs valueForKey: @"username"];
    NSLog(@"Hello, %@", userName);
    
    if( [userName length] == 0 ) {
        [self whoAreYou];
    } else {
        textArea.text = userName;
        [textArea setHidden: YES];
    }
}

-(void) whoAreYou
{
    [textArea setHidden: NO];
}

- (void) setUserName:(NSString*) name {
    userName = name;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: userName forKey:@"username"];
}

- (void) slapModeFor:(NSString*) name at:(NSString*) phone with:(double) ferocity
{
    self.fiveCompanion.text = name;
    targetAddress = phone;
    uiMode = kSLAP_MODE;
}

- (void) waitingMode {
    uiMode = kWAITING_MODE;
    self.fiveCompanion.text = @"Tap to Slap";
}

//screen touch
- (IBAction)screenTap:(UITapGestureRecognizer*)sender {
    if (uiMode == kWAITING_MODE) {
        ABPeoplePickerNavigationController *picker =[[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        [self presentViewController: picker animated:YES completion:nil];
    }
}

- (IBAction)reset:(id)sender {
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    currentMaxAccelZ = 0;
}

//accelerometer
-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    currentMaxAccelX = MAX(fabs(acceleration.x), currentMaxAccelX);
    currentMaxAccelY = MAX(fabs(acceleration.y), currentMaxAccelY);
    currentMaxAccelZ = MAX(fabs(acceleration.z), currentMaxAccelZ);
    
    if ( uiMode == kSLAP_MODE && [Slapperometer slapCheck:acceleration] ) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        //[imagePicker takePicture];
        [SlapNet sendSlap: currentMaxAccelZ to: targetAddress as: userName];
        [self waitingMode];
    }
}

//PEOPLE PICKER
-(void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person,kABPersonFirstNameProperty);
    
    //TODO Mobile phone?
    NSString* phone = @"";
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc] initWithObjects:@[@"", @""] forKeys:@[@"mobileNumber", @"homeNumber",]];
    
    ABMultiValueRef *phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
    {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phones, j);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phones, j);
        
        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
        }
        
        if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"homeNumber"];
        }
        
        CFRelease(currentPhoneLabel);
        CFRelease(currentPhoneValue);
    }
    
    if ([phone isEqual:@""]) {
        phone = [contactInfoDict valueForKeyPath:@"mobileNumber"];
    }
    
    if ([phone isEqual:@""]) {
        phone = [contactInfoDict valueForKeyPath:@"homeNumber"];
    }
    
    phone = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789+"] invertedSet]] componentsJoinedByString:@""];
    NSLog(@"(%@)", phone);
    
    if ( [phone length] > 0) {
        [self slapModeFor:name at:phone with: 0];
    } else {
        NSString *msg = [NSString stringWithFormat:@"It looks like %@ doesn't have a phone number", name];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Woah Dawg" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    CFRelease(phones);

    [self dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

//SMS MESSAGE Compose
-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{ [self dismissViewControllerAnimated:YES completion:nil];}

//image capture
/*
- (void) configureCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"Camera loaded.");
        //NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //imagePicker.cameraCaptureMode = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        //imagePicker.showsCameraControls = NO;
        //imagePicker.cameraOverlayView = self.view;
        //imagePicker.allowsEditing = YES;
        [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
    } else {
        NSLog(@"Sorry! No Camera");
    }
    //UIImage * flippedImage = [UIImage imageWithCGImage:picture.CGImage scale:picture.scale orientation:UIImageOrientationLeftMirrored];

}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"photo taken");
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImageView *iv = [[UIImageView alloc] initWithImage:image];
    [self.view addSubview: iv];
    
}*/

//textfield

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self setUserName: textField.text];
    [textField resignFirstResponder];
    return NO;
}
@end
