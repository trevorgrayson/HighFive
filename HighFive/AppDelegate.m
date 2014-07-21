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
    //if [url path] == ridiculous

    NSArray *urlArray = [[url query] componentsSeparatedByString:@"&"];
    
    double fierocity = [urlArray[0] doubleValue];
    NSString *senderId = urlArray[1];

    ViewController *root = (ViewController*) self.window.rootViewController;
    
    if([urlArray count] > 2) {
        NSString *name = urlArray[2];
        [root receiveHighFive:fierocity from:senderId as: name];
    } else {
        [root receiveHighFive:fierocity from:senderId];
    }

    return YES;
}

- (void) respondToSlap:(double)ferocity from:(NSString*) phone as:(NSString*) name
{
    ViewController *root = (ViewController*) self.window.rootViewController;
    [root slapModeFor: phone at: phone with: ferocity];
}

- (void) respondToSlap:(double)ferocity from:(NSString*) phone
{
    [self respondToSlap:ferocity from: phone as: phone];
    
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
    // Override point for customization after application launch.
    return YES;
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
