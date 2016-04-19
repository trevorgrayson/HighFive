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
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken = [prefs objectForKey: @"deviceToken"];
    NSString *contact     = [prefs objectForKey: @"contact"];
    NSString *name        = [prefs objectForKey: @"name"];
    NSLog(@"%@ %@ %@", name, contact, deviceToken);
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    
    for (UILocalNotification *notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        [self processNotification: [notification userInfo]];
    }
    //[[UIApplication sharedApplication] cancelAllLocalNotifications]; //clear notifications
    
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"highfive-0" withExtension:@"m4a"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &slapSound);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {   // This code will work in iOS 7.0 and below:
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    if(contact == nil) {
        [self invitationBlock];
    }
    
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
        
        if(contact != nil) {
            [self welcome];
            [self attemptRegistration];
        }
    }
    
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)newDeviceToken forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    if ([newDeviceToken isEqualToString:@"declineAction"]){
        NSLog(@"User Declined Notifications");
    } else if ([newDeviceToken isEqualToString:@"answerAction"]) {
        NSString *devTokenStr = [[[[newDeviceToken description]
                                   stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                  stringByReplacingOccurrencesOfString: @">" withString: @""]
                                 stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSLog(@"setting %@", devTokenStr);
        [prefs setObject: devTokenStr forKey:@"deviceToken"];
        [prefs synchronize];
        
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
    
    NSLog(@"My token is: %@", devTokenStr);
}

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
    
    if( deviceToken != nil && contact != nil ) { //TODO
        [SlapNet registerUser:deviceToken identifiedBy:contact as:name];
    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [self processNotification: [notification userInfo] ];
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self processNotification: userInfo];
}

- (void) processNotification:(NSDictionary*) userInfo {
    notificationCount++;
    
    NSDictionary *slap = [userInfo valueForKeyPath:@"slap"];
    
    NSString *phone = [slap valueForKey:@"id"];
    NSString *name  = [slap valueForKey:@"from"];
    
    if(name == nil) {
        [AddressNameLookup contactContainingPhoneNumber: phone];
    }
    
    double jerk = [[slap valueForKeyPath:@"jerk"] doubleValue];
    
    User *slapper = [[User alloc] init: name with: phone];
    Slap *incoming = [[Slap alloc] init:slapper with: jerk];
    
    [Inbox addMessage: incoming];
    [self respondToSlap: jerk from: slapper];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = [Inbox count];
    
    [self playSlapSound];
}

- (void) playSlapSound {
    AudioServicesPlaySystemSound(slapSound);
}

- (void) respondToSlap:(double)ferocity from:(User*) user {
    ViewController *root = (ViewController*) self.window.rootViewController;
    [root receiveHighFive:ferocity from:user];
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
