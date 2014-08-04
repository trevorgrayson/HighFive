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
@synthesize messages;
@synthesize targetRecipient;
@synthesize imagePicker;

//TODO ENUMs
int kWAITING_MODE =0;
int kSLAP_MODE = 1;

NSString *userName = nil;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    messages = [[NSMutableDictionary alloc] init];
    [self reset:nil];
    [self waitingMode];
    targetRecipient = nil;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
        [self outputAccelertionData:accelerometerData.acceleration];
        
        if(error){ NSLog(@"%@", error); }
    }];
    //[self configureCamera];
    [self checkUserName];
    
    //GYRO DATA
    //[self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
    //[self outputRotationData:gyroData.rotationRate]; }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTap:)];
    [self.hand addGestureRecognizer: tap];
}

- (void) receiveHighFive:(double) ferocity from:(User*) user
{
    //[self slapModeFor: name at: contact with:ferocity];
    NSNumber *newValue;
    
    if( [messages objectForKey: user.name] == nil ) {
        newValue = [NSNumber numberWithInt:1];
    } else {
        NSNumber *currentCount = [messages valueForKey: user.name];
        newValue = [NSNumber numberWithInt: [currentCount intValue] + 1];
    }
    
    [messages setValue: newValue forKey: user.name];
    
    HandWidget *hw = [[HandWidget alloc] initWithCount: [newValue intValue]
                                              andFrame: CGRectMake(self.view.frame.origin.x + 2,
                                                                   self.view.frame.origin.y +
                                                                   self.view.frame.size.height - 50 - 2,
                                                                   50, 50)];
    [self.view addSubview: hw];
    
    hw.userInteractionEnabled = YES;
    hw.user = user;
    hw.count = [newValue intValue];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [hw addGestureRecognizer: tap];
}

//f(x)

-(void) tap:(id) sender {
    HandWidget *hw = (HandWidget*) sender;
    [self slapModeFor: hw.user with: 1.2];
}

-(void) checkUserName
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    userName = [prefs valueForKey: @"username"];
    NSLog(@"Hello, %@", userName);
}

-(void) whoAreYou
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"High Five!" message:@"Nice slap, guy. What's your name bro?" delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Done", nil];
    [alert setAlertViewStyle: UIAlertViewStylePlainTextInput];
    [alert show];
}
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    UITextField *textField = [alertView textFieldAtIndex:0];

    switch (buttonIndex) {
        case 1:
            [self setUserName: textField.text];
            [self sendSlap];
            break;
            
        default:
            break;
    }
}

- (void) setUserName:(NSString*) name {
    userName = name;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject: userName forKey:@"username"];
}

- (void) slapModeFor:(User*) user with:(double) ferocity {
    self.fiveCompanion.text = user.name;
    targetRecipient = user;
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
        [self sendSlap];
        [self waitingMode];
    }
}

-(void) sendSlap {
    NSLog(@"username: %@", userName);
    if( [userName length] == 0 ) {
        [self whoAreYou];
    } else {
        [SlapNet sendSlap: currentMaxAccelZ to: targetRecipient];
    }
}
//PEOPLE PICKER
-(void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person,kABPersonFirstNameProperty);
    
    //TODO Mobile phone?
    NSString* phone = @"";
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc] initWithObjects:@[@"", @""] forKeys:@[@"mobileNumber", @"homeNumber",]];
    
    ABMultiValueRef *phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    NSLog(@"Phone Count: %ld",  ABMultiValueGetCount(phones));
    for(CFIndex j = 0; j < ABMultiValueGetCount(phones); j++)
    {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phones, j);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phones, j);
        
        NSLog(@"Phone maybe (%@)", (__bridge NSString *)currentPhoneValue);
        if (j == 0) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            phone = (__bridge NSString *)currentPhoneValue;
        }
        if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"mobileNumber"];
            phone = (__bridge NSString *)currentPhoneValue;
            continue;
        }
        
        if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
            [contactInfoDict setObject:(__bridge NSString *)currentPhoneValue forKey:@"homeNumber"];
        }
        
        CFRelease(currentPhoneLabel);
        CFRelease(currentPhoneValue);
    }
    
    if ([phone isEqual:@""]) {
        phone = [contactInfoDict valueForKeyPath:@"homeNumber"];
    }
    
    phone = [[phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789+"] invertedSet]] componentsJoinedByString:@""];
    NSLog(@"(%@)", phone);
    
    if ( [phone length] > 0) {
        User  *target = [[User alloc] init: name with: phone];
        [self slapModeFor:target with: 0];
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
