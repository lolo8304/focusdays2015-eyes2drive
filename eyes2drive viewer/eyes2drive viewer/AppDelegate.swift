//
//  AppDelegate.swift
//  eyes2drive viewer
//
//  Created by Lorenz Hänggi on 18/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import UIKit
import Foundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
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
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }

    
    //Aus dem Delegate der WatchKit-App: antwortet auf einen Request von der WatchKit App
    //siehe GlanceController willActivate
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?,
        reply: (([NSObject : AnyObject]!) -> Void)!) {
            
            if ((userInfo?["glanceValues"]) != nil) {
                var score = NSNumber(integer: 0)
                var green = NSNumber(integer: 0)
                var orange = NSNumber(integer: 0)
                var red = NSNumber(integer: 0)
                var duration = NSNumber(integer: 0)

                if (eyeHandler.tripsRepo.trips.count > 0) {
                    let trip = eyeHandler.tripsRepo.getCurrentTrip()
                    let dashboard = trip.generateDashboard()
                
                    score = NSNumber(integer: dashboard.scoreInPercent)
                    green = NSNumber(integer: dashboard.greenDurationInPercent)
                    orange = NSNumber(integer: dashboard.orangeDurationInPercent)
                    red = NSNumber(integer: dashboard.redDurationInPercent)
                    duration = NSNumber(double: dashboard.totalS)
                }
            
                reply(["score":score, "green":green, "orange":orange, "red":red, "duration":duration])
            } else if ((userInfo?["graphValues"]) != nil) {
                if (eyeHandler.tripsRepo.trips.count > 0) {
                    let trip = eyeHandler.tripsRepo.getCurrentTrip()

                }
                reply(["trip":"aaaa"])
                
            }
    }
    
    
    
    func initBTLE(){
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var channelIndex: Int = defaults.integerForKey("btleChannelIndex")
        var chan32: Int32 = Int32(channelIndex)
        TransferService.setValue(chan32);
    }
}

