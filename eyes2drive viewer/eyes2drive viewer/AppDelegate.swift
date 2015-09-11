//
//  AppDelegate.swift
//  eyes2drive viewer
//
//  Created by Lorenz Hänggi on 18/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//
// installing cocoapads: https://guides.cocoapods.org/using/using-cocoapods.html
// installing Async: 
//      pod https://github.com/duemunk/async or
// using NSTimer http://stackoverflow.com/questions/25951980/swift-do-something-every-x-minutes
// run HTTP call asynchronous http://stackoverflow.com/questions/24016142/how-to-make-an-http-request-in-swift
// JSON with Swift:
//      http://www.raywenderlich.com/82706/working-with-json-in-swift-tutorial
//      https://github.com/lingoer/SwiftyJSON / Pod does not work, copy paste and fixed for Swift 1.2

import UIKit
import Foundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var updateEvents: NSTimer?
    var updateEventsRunning: Bool = false
    
    
    
    func updateEventsFromServer()
    {
        if (!self.updateEventsRunning) {
            self.updateEventsRunning = true;
            NSLog("process 'updateEvents' reserved")
            
            let url = NSURL(string: "http://tomcat7-focusdays2015.rhcloud.com/rest/devices")
            let request = NSURLRequest(URL: url!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in

                //print out full data string for debug
                println(NSString(data: data, encoding: NSUTF8StringEncoding))
                
                //use SwiftyJSON
                let json = JSON(data: data)
                if let device = json[0]["device-id"].string {
                    println(device)
                }
                
                self.updateEventsRunning = false
                NSLog("process 'updateEvents' released")
            }
            
        } else {
            NSLog("process 'updateEvents' is still running")
        }
    }


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        self.updateEvents = NSTimer.scheduledTimerWithTimeInterval(6.0, target: self, selector: Selector("updateEventsFromServer"), userInfo: nil, repeats: true)
        
        /* tip
            https://thatthinginswift.com/remote-notifications/
        */
        let settings = UIUserNotificationSettings(forTypes: .Alert | .Badge | .Sound, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        initBTLE()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        initBTLE()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        updateEvents?.invalidate()
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    /* tip
    http://stackoverflow.com/questions/9372815/how-can-i-convert-my-device-token-nsdata-into-an-nsstring
    */
    func deviceIdAsString(deviceToken: NSData) -> NSString {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        return tokenString
    }

    /* tip
        https://thatthinginswift.com/remote-notifications/
        save device-id on server: https://blog.serverdensity.com/how-to-build-an-apple-push-notification-provider-server-tutorial/
    */
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let deviceTokenString = self.deviceIdAsString(deviceToken)
        NSLog("My token is: %@", deviceTokenString);
        
        // http://tomcat7-focusdays2015.rhcloud.com/rest/device/%@"
        let url = String(format:"http://tomcat7-focusdays2015.rhcloud.com/rest/device/%@", deviceTokenString)
        
        let req = Agent.put(url)
        req.end({ (response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void in
            NSLog("device registered with id %@", deviceTokenString);
        })
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("Couldn't register: \(error)")
    }

    
    //Aus dem Delegate der WatchKit-App: antwortet auf einen Request von der WatchKit App
    //siehe GlanceController willActivate
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?,
        reply: (([NSObject : AnyObject]!) -> Void)!) {
            
            var score = NSNumber(integer: 0)
            var green = NSNumber(integer: 0)
            var orange = NSNumber(integer: 0)
            var red = NSNumber(integer: 0)

            if (eyeHandler.tripsRepo.trips.count > 0) {
                let trip = eyeHandler.tripsRepo.getCurrentTrip()
                let dashboard = trip.generateDashboard()
                
                score = NSNumber(integer: dashboard.scoreInPercent)
                green = NSNumber(integer: dashboard.greenDurationInPercent)
                orange = NSNumber(integer: dashboard.orangeDurationInPercent)
                red = NSNumber(integer: dashboard.redDurationInPercent)
            }
            
            reply(["score":score, "green":green, "orange":orange, "red":red])
    }
    
    
    
    func initBTLE(){
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var channelIndex: Int = defaults.integerForKey("btleChannelIndex")
        var chan32: Int32 = Int32(channelIndex)
        TransferService.setValue(chan32);
    }
}

