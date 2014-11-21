//
//  ViewController.m
//  HighFive
//
//  Created by Trevor Grayson on 7/18/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "ViewController.h"
#import "ContactInfoDelegate.h"
#import "AddressNameLookup.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize nameTag;
@synthesize messages;
@synthesize targetRecipient;
@synthesize imagePicker;

//TODO ENUMs
int kWAITING_MODE = 0;
int kSLAP_MODE    = 1;
int kINVITE_ONLY  = 2;

SystemSoundID slapSound;

NSMutableDictionary *handWidgets = nil;

- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    [super viewDidLoad];
    uiMode = kINVITE_ONLY;
    
    handWidgets = [[NSMutableDictionary alloc] init];
    
    messages = [[NSMutableDictionary alloc] init];
    [self reset:nil];
    targetRecipient = nil;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
        [self outputAccelertionData:accelerometerData.acceleration];
        
        if(error){ NSLog(@"%@", error); }
    }];
    //[self configureCamera];
    
    //GYRO DATA
    //[self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
    //[self outputRotationData:gyroData.rotationRate]; }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTap:)];
    [self.hand addGestureRecognizer: tap];
    
//    UIAlertView* contactInfoDel = [ContactInfoDelegate checkForContactInfo];
//    if( contactInfoDel ) {
//        [contactInfoDel show];
//    }
    
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"highfive-0" withExtension:@"m4a"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &slapSound);
}

- (void)viewDidAppear:(BOOL)animated {
    if([self checkContact] && uiMode == kINVITE_ONLY) {
        [self waitingMode];
    }
}

- (void) setName:(NSString*) name
{
    [nameTag setTitle: name forState:UIControlStateNormal];
}

- (IBAction)changeName:(id)sender {
    [self whoAreYou];
}

- (void) receiveHighFive:(double) ferocity from:(User*) user
{
    NSString *key = user.contact;
    //[self slapModeFor: name at: contact with:ferocity];
    NSNumber *newValue;
    
    if( [messages objectForKey: key] == nil ) {
        newValue = [NSNumber numberWithInt:1];
    } else {
        NSNumber *currentCount = [messages valueForKey: key];
        newValue = [NSNumber numberWithInt: [currentCount intValue] + 1];
    }
    
    [messages setValue: newValue forKey: key];
    
    HandWidget *hw;
    
    //TODO what about multiple users sending messages? Move along the bottom
    if( [handWidgets objectForKey: key] == nil ) {
        float width = 50;
        float iconCount = (float)[[handWidgets allKeys] count];
        float delta = (width + 10.0f) * iconCount;
        hw = [[HandWidget alloc] initWithCount: [newValue intValue]];
        [hw setFrame: CGRectMake(self.view.frame.origin.x + 2.0f + delta,
                                                                       self.view.frame.origin.y +
                                                                       self.view.frame.size.height - width - 2.0f,
                                                                       width, width)];
        hw.userInteractionEnabled = YES;
        hw.user = user;
        
        [handWidgets setValue: hw forKeyPath: key];
        [self.view addSubview: hw];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [hw addGestureRecognizer: tap];
    } else {
        hw = (HandWidget*) [handWidgets objectForKey: user.contact];
    }
    
    [hw addFerocity: ferocity];
    [hw setNum: [newValue intValue]];
}

//f(x)

-(void) tap:(UITapGestureRecognizer*) sender {
    HandWidget *hw = (HandWidget*) sender.view;
    [self slapModeFor: hw.user with: hw.maxSlapFerocity];
}

-(BOOL) checkContact {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs valueForKey: @"contact"] != nil;
}

-(void) whoAreYou
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"High Five!" message:@"What's your name bro?" delegate:self cancelButtonTitle:@"Burn" otherButtonTitles:@"Hello", nil];
    [alert setAlertViewStyle: UIAlertViewStylePlainTextInput];
    [alert show];
}

- (void) slapModeFor:(User*) user with:(double) ferocity {
    self.fiveCompanion.text = user.name;
    targetRecipient = user;
    [self.redHand setAlpha: ferocity/10];
    uiMode = kSLAP_MODE;
}

- (void) waitingMode {
    uiMode = kWAITING_MODE;
    self.fiveCompanion.text = @"Tap to Slap";
    [self.redHand setAlpha: 0];
    [self.inviteOnly setHidden: YES];
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
        [self sendSlap];
        [self waitingMode];
    }
}

-(void) sendSlap {
    [SlapNet sendSlap: currentMaxAccelZ to: targetRecipient];
    AudioServicesPlaySystemSound(slapSound);
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

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
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
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)pinchhack:(id)sender {
    if ( uiMode == kSLAP_MODE ) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        //[imagePicker takePicture];
        [self sendSlap];
        [self waitingMode];
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if( motion == UIEventSubtypeMotionShake) {
        //1User *slapper = [[User alloc] init: @"T-Dizzle" with: @"8603849759"];
        //[SlapNet receiveHighFive: 1.0 from:slapper];
    }
}

@end
