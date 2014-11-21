//
//  AppDelegate.m
//  HighFive
//
//  Created by Trevor Grayson on 7/18/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "AddressNameLookup.h"
#import "SlapAlert.h"

@implementation AppDelegate

@synthesize notificationCount;

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSArray *urlArray = [[url path] componentsSeparatedByString:@"/"];
    
    if([url.host isEqual: @"invite"]) {
        NSString *contact = urlArray[1];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSLog(@"setting contact: %@", contact);
        [prefs setObject: contact forKey:@"contact"];
        [prefs synchronize];
        
        [self attemptRegistration];
        ViewController *root = (ViewController*) self.window.rootViewController;
        [root waitingMode];
    }
    
    return YES;
}

- (void) attemptRegistration {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [prefs objectForKey: @"deviceToken"];
    NSString *contact = [prefs objectForKey: @"contact"];

    if( deviceToken != nil && contact != nil ) {
        [SlapNet registerUser:deviceToken identifiedBy:contact];
    }
}


//- (void) receiveHighFiveFromOpenUrl {
//ensure/request deviceToken
//if invite link = get link from invite code
//[SlapNet registerUser: @"" identifiedBy:@""];
//ViewController *root = (ViewController*) self.window.rootViewController;
//    //if [url path] == ridiculous
//    NSArray *urlArray = [[url query] componentsSeparatedByString:@"&"];
//    
//    double fierocity = [urlArray[0] doubleValue];
//    NSString *senderId = urlArray[1];
//    NSString *name = senderId;
//    User *slapper = [[User alloc] init:name with:senderId];
//    
//    if([urlArray count] > 2) {
//        name = urlArray[2];
//    }
//    
//    [root receiveHighFive:fierocity from: slapper];
//}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    notificationCount++;
    
    NSDictionary *slap = [userInfo valueForKeyPath:@"slap"];
    
    NSString *phone = [slap valueForKeyPath:@"id"];
    //NSString *name = [slap valueForKeyPath:@"name"];
    NSString *name = [AddressNameLookup contactContainingPhoneNumber: phone];
    double jerk = [[slap valueForKeyPath:@"jerk"] doubleValue];
    
    User *slapper = [[User alloc] init: name with: phone];
    Slap *incoming = [[Slap alloc] init:slapper with: jerk];
    //if(UIApplication.application.state){
    [self respondToSlap: jerk from: slapper];

    SlapAlert *alert = [SlapAlert newAlert: incoming];
    [alert show];
}

- (void) respondToSlap:(double)ferocity from:(User*) user {
    ViewController *root = (ViewController*) self.window.rootViewController;
    [root receiveHighFive:ferocity from:user];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[NSNotificationCenter defaultCenter] addObserverForName: @"SLAP" object:nil queue:nil usingBlock:^(NSNotification *note) {
//        Slap *slap = (Slap*)note.object;
//        ViewController* vc= (ViewController*)self.window.rootViewController;
//        
//        [vc slapModeFor: slap];
//    }];
     //addObserver: self selector: @selector(respondToSlap:from:) name:@"SLAP" object:nil];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    NSLog(@"%@", launchOptions);
    [self attemptRegistration];
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)newDeviceToken
{
    NSString *devTokenStr = [[[[newDeviceToken description]
                               stringByReplacingOccurrencesOfString: @"<" withString: @""]
                               stringByReplacingOccurrencesOfString: @">" withString: @""]
                               stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSLog(@"setting %@", devTokenStr);
    [prefs setObject: devTokenStr forKey:@"deviceToken"];
    [prefs synchronize];
    [self attemptRegistration];

	NSLog(@"My token is: %@", devTokenStr);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Memory warning, bro." message:@"Close some apps guy, your device is out of control." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

@end
