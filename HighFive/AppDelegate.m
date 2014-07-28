//
//  AppDelegate.m
//  HighFive
//
//  Created by Trevor Grayson on 7/18/14.
//  Copyright (c) 2014 Ipsum LLC. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    ViewController *root = (ViewController*) self.window.rootViewController;
    
    //if [url path] == ridiculous
        NSArray *urlArray = [[url query] componentsSeparatedByString:@"&"];
    
    double fierocity = [urlArray[0] doubleValue];
    NSString *senderId = urlArray[1];
    NSString *name = senderId;

    if([urlArray count] > 2) {
        name = urlArray[2];
    }
    
    [root receiveHighFive:fierocity from:senderId as: name];

    return YES;
}

- (void) respondToSlap:(double)ferocity from:(NSString*) phone as:(NSString*) name
{
    ViewController *root = (ViewController*) self.window.rootViewController;
    [root receiveHighFive: ferocity from: phone as: name];
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSDictionary *slap = [userInfo valueForKeyPath:@"slap"];
    
    NSString *phone = [slap valueForKeyPath:@"id"];
    NSString *name = [slap valueForKeyPath:@"name"];
    double jerk = [[slap valueForKeyPath:@"jerk"] doubleValue];

    //if(UIApplication.application.state){ // 
    [self respondToSlap: jerk from: phone as: name];
    NSString *msg = [NSString stringWithFormat:@"%@ high fived you!", name];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Slap!!" message: msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
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
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}





							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //self.window.rootViewController
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
