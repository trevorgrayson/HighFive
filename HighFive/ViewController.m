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

//TODO ENUMs
int kWAITING_MODE =0;
int kSLAP_MODE = 1;

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
        
        if(error){
            NSLog(@"%@", error);
        }
    }];
    
//    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
//  [self outputRotationData:gyroData.rotationRate]; }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTap:)];
    [self.view addGestureRecognizer: tap];
}

- (IBAction)screenTap:(id)sender {
    if (uiMode == kWAITING_MODE) {
        ABPeoplePickerNavigationController *picker =[[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        [self presentViewController: picker animated:YES completion:nil];
    }
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    currentMaxAccelX = MAX(fabs(acceleration.x), currentMaxAccelX);
    currentMaxAccelY = MAX(fabs(acceleration.y), currentMaxAccelY);
    currentMaxAccelZ = MAX(fabs(acceleration.z), currentMaxAccelZ);
    
    if ( uiMode == kSLAP_MODE && [Slapperometer slapCheck:acceleration] ) {
        [self waitingMode];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        self.slapDebug.text = [NSString stringWithFormat: @"SLAP! %4.2f, %4.2f %4.2f", currentMaxAccelX, currentMaxAccelY, currentMaxAccelZ];
        NSLog(@"SNAP %@", imagePicker);
        [imagePicker takePicture];
        
        if (false /*confirmation config?*/) {
            NSString *msg = [NSString stringWithFormat:@"You just slapped a %4.2f! Send this?", currentMaxAccelZ];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SLAP!" message:msg delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles: @"Send", nil];
            [alert show];
        } else {
           [self sendHighFive:currentMaxAccelZ to: targetAddress];
        }
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            [self sendHighFive:currentMaxAccelZ to: targetAddress];
            break;
            
        default:
            uiMode = kSLAP_MODE;
            break;
    }
}

- (IBAction)reset:(id)sender {
    currentMaxAccelX = 0;
    currentMaxAccelY = 0;
    currentMaxAccelZ = 0;
}

- (void) sendHighFive:(double) ferocity to:(NSString*) contact
{
    self.fiveCompanion.text = @"Tap";
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = [NSString stringWithFormat: @"HIGH FIVE! You just got hit with a %@ %4.2f slap. Slap me back", [self highFiveDescription:ferocity], ferocity];
        controller.recipients = [NSArray arrayWithObjects: targetAddress, nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
        [self reset:nil];
    }
}

-(NSString*) highFiveDescription:(double) m/*agnetude*/ {
    
    NSString *judgement = @"passable";
    
    if(m > 8) {
        judgement = @"tremendous";
    } else if(m > 7) {
        judgement = @"fierce";
    } else if(m > 6) {
        judgement = @"braggable";
    } else if(m > 5) {
        judgement = @"strong";
    } else if(m > 4) {
        judgement = @"aggressive";
    } else if(m > 3) {
        judgement = @"strong";
    } else if(m > 2) {
        judgement = @"solid";
    }

    return judgement;
}

- (void) waitingMode {
    uiMode = kWAITING_MODE;
}

//PEOPLE PICKER
-(void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    uiMode = kSLAP_MODE;
    
    NSString* name = (__bridge_transfer NSString*)ABRecordCopyValue(person,kABPersonFirstNameProperty);
    
    //TODO Mobile phone?
    NSString* phone = @"";
    NSMutableDictionary *contactInfoDict = [[NSMutableDictionary alloc]
                                            initWithObjects:@[@"", @""]
                                            forKeys:@[@"mobileNumber", @"homeNumber",]];
    
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
    
    NSLog(@"(%@)", phone);
    
    if ( [phone length] > 0) {
        targetAddress = phone;
        self.fiveCompanion.text = name;
    } else {
        NSString *msg = [NSString stringWithFormat:@"It looks like %@ doesn't have a phone number", name];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Woah Dawg" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
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

//MESSAGE

-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
