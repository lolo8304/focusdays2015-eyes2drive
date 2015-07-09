//
//  AppDelegate.m
//  FacialFeatures
//
//  Copyright (c) 2013 Luxand, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#include "LuxandFaceSDK.h"

@implementation AppDelegate

// Is not needed in Xcode 4.4+
@synthesize window=_window;
@synthesize viewController=_viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    int res = FSDK_ActivateLibrary((char *)"");
    NSLog(@"activation result %d\n", res);
    if (res) exit(res);
    
    char licenseInfo[1024];
    FSDK_GetLicenseInfo(licenseInfo);
    NSLog(@"license: %s\n", licenseInfo);
    
    res = FSDK_Initialize((char *)"");
    NSLog(@"init result %d\n", res);
    if (res) exit(res);

    int threadcount = 0;
    res = FSDK_GetNumThreads(&threadcount);
    NSLog(@"thread count %d\n", threadcount);
    if (res) exit(res);
    
    FSDK_SetFaceDetectionParameters(false, false, 120);
    FSDK_SetFaceDetectionThreshold(5);

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
