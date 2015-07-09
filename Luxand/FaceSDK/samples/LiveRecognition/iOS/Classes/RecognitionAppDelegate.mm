//
//  based on ColorTrackingAppDelegate.m
//  from ColorTracking application
//  The source code for this application is available under a BSD license.
//  See ColorTrackingLicense.txt for details.
//  Created by Brad Larson on 10/7/2010.
//  Modified by Anton Malyshev on 6/21/2013.
//

#import "RecognitionAppDelegate.h"
#import "RecognitionViewController.h"
#include "LuxandFaceSDK.h"

@implementation RecognitionAppDelegate

@synthesize window = _window;
//@synthesize viewController = _viewController;

- (void)dealloc {
    [recognitionViewController release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    int res = FSDKE_OK; 
    res = FSDK_ActivateLibrary((char *)"");
#if defined(DEBUG)
    NSLog(@"activation result %d\n", res);
#endif    
    if (res) exit(res);
    
    char licenseInfo[1024];
    FSDK_GetLicenseInfo(licenseInfo);
#if defined(DEBUG)
    NSLog(@"license: %s\n", licenseInfo);
#endif
    
    res = FSDK_Initialize((char *)"");
#if defined(DEBUG)
    NSLog(@"init result %d\n", res);
#endif
    if (res) exit(res);
    
    //uncomment call FSDK_SetNumThreads(1) to detect and recognize faces using only 1 thread for more smooth video on multicore device, such as iPhone 4S+ and iPad 2+ (if detecting face async)
    //comment-out if faster detection and recognition is needed
    //res = FSDK_SetNumThreads(1);
    
    int threadcount = 0;
    res = FSDK_GetNumThreads(&threadcount);
#if defined(DEBUG)
    NSLog(@"thread count %d\n", threadcount);
#endif
    if (res) exit(res);
    
    //does not affect tracker performance
    //FSDK_SetFaceDetectionParameters(false, false, 70);
    //FSDK_SetFaceDetectionThreshold(5);
    
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	if (!_window) {
		[self release];
		return NO;
	}
	_window.backgroundColor = [UIColor blackColor];
	_window.autoresizesSubviews = YES;
	_window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
    // init our view controller
    recognitionViewController = [[RecognitionViewController alloc] initWithScreen:[UIScreen mainScreen]];
    // and add it to the window
    //[_window addSubview:recognitionViewController.view];
	[self.window setRootViewController:recognitionViewController]; //more correct way
    
    [_window makeKeyAndVisible];
	[_window layoutSubviews]; //isn't necessary	

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */

    recognitionViewController.closing = YES;
    
    int i = 1;
    while (recognitionViewController.processingImage) {
        //wait while processing Image in FaceSDK, but not more than 2 seconds
        if (i++ > 20) break; 
        [NSThread sleepForTimeInterval:0.1];
    }
    
    int res = FSDKE_OK;
    res = FSDK_SaveTrackerMemoryToFile(recognitionViewController.tracker, recognitionViewController.templatePath);
#if defined(DEBUG)    
    NSLog(@"saved tracker memory to %s with %d\n", recognitionViewController.templatePath, res);
#endif
    free(recognitionViewController.templatePath);
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

@end
