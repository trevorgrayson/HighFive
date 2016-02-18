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
#import "SlapLocalNotification.h"
#import "Inbox.h"
#import "InviteWallController.h"

@implementation AppDelegate

@synthesize notificationCount;
@synthesize slapSound;
@synthesize invitationWall;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //clear notifications
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationSupportsShakeToEdit = YES;
    
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"highfive-0" withExtension:@"m4a"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &slapSound);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    // This code will work in iOS 7.0 and below:
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    [self attemptRegistration];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (NSString *param in [[url query] componentsSeparatedByString:@"&"]) {
        NSArray *parts = [param componentsSeparatedByString:@"="];
        if([parts count] < 2) continue;
        [params setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
    }
    
    if([url.host isEqual: @"invite"]) {
        NSString *contact = [params objectForKey:@"invite"];
        NSString *name    = [params objectForKey:@"name"];
        NSLog(@"setting contact: %@", contact);
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject: contact forKey:@"contact"];
        [prefs setObject: name    forKey:@"name"];
        [prefs synchronize];
        
        [self attemptRegistration];
    }
    
    return YES;
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    notificationCount++;
    
    NSDictionary *slap = [userInfo valueForKeyPath:@"slap"];
    
    NSString *phone = [slap valueForKey:@"id"];
    NSString *name  = [slap valueForKey:@"name"];
    
    if(name == nil) {
        [AddressNameLookup contactContainingPhoneNumber: phone];
    }

    double jerk = [[slap valueForKeyPath:@"jerk"] doubleValue];
    
    User *slapper = [[User alloc] init: name with: phone];
    Slap *incoming = [[Slap alloc] init:slapper with: jerk];
    //if(UIApplication.application.state){
    [Inbox addMessage: incoming];
    [self respondToSlap: jerk from: slapper];

    [UIApplication sharedApplication].applicationIconBadgeNumber = [Inbox count];
    
    [self playSlapSound];
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)newDeviceToken forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([newDeviceToken isEqualToString:@"declineAction"]){
        NSLog(@"User Declined Notifications");
    }
    else if ([newDeviceToken isEqualToString:@"answerAction"]){
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
}
#endif

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

//Could cache result and stop multiple requests
- (void) attemptRegistration {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [prefs objectForKey: @"deviceToken"];
    NSString *contact     = [prefs objectForKey: @"contact"];
    NSString *name        = [prefs objectForKey: @"name"];
    
    if( contact == nil ) {
        [self invitationBlock];
    } else {
        [self welcome];
    }
    
    NSLog(@"thinking about registering: %@ %@", deviceToken, contact);
    
    if( deviceToken != nil && contact != nil ) {
        [SlapNet registerUser:deviceToken identifiedBy:contact as:name];
    }
}

- (void) playSlapSound {
    AudioServicesPlaySystemSound(slapSound);
}

- (void) respondToSlap:(double)ferocity from:(User*) user {
    ViewController *root = (ViewController*) self.window.rootViewController;
    [root receiveHighFive:ferocity from:user];
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Memory warning, bro." message:@"Close some apps guy, your device is out of control." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

-(void) welcome {
    if( self.window.rootViewController == invitationWall )
    {
        [self.window.rootViewController.navigationController popViewControllerAnimated:NO];
        
        UIStoryboard *sb        = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc    = [sb instantiateViewControllerWithIdentifier:@"tableCont"];
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self.window.rootViewController presentViewController:vc animated:YES completion:NULL];
    }

}

-(void) invitationBlock {
    if( invitationWall == nil) {
        InviteWallController *wall = [[InviteWallController alloc] init];
        self.window.rootViewController = wall;
        invitationWall = wall;
        NSLog(@"Register son");
    }
}
@end
