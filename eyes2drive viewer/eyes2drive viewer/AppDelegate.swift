//
//  AppDelegate.swift
//  eyes2drive viewer
//
//  Created by Lorenz Hänggi on 18/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import UIKit
import Foundation
import WatchConnectivity

/* watch OS2 connectivity
http://www.kristinathai.com/watchos-2-tutorial-using-sendmessage-for-instantaneous-data-transfer-watch-connectivity-1/
*/

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate, ReceiverDelegate {

    var window: UIWindow?
    var central = BTLECentral()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        initBTLE()
        
        if #available(iOS 9.0, *) {
            initWCSession2()
        } else {
            initWCSession1()
        }
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
    
    func getGlanceValues()->[String : AnyObject]{
        if (eyeHandler.hasTrips()) {
            return Dashboard(eyeHandler.getCurrentTrip()).json()[0]
        } else {
            return ["score":0, "green":0, "orange":0, "red":0, "duration":0]
        }
    }
    func getGraphValues()->Array<[String : AnyObject]>{
        if (eyeHandler.hasTrips()) {
            return DashboardDetails(eyeHandler.getCurrentTrip()).json()
        } else {
            return Array<[String : AnyObject]>()
        }
    }

    // watchKit Version 2
    // WCSessionDelegate

    @available(iOS 9.0, *)
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        NSLog("WC session: message received")

        if ((message["glanceValues"]) != nil) {
            NSLog("WC session: reply #glanceValues")
            replyHandler(self.getGlanceValues())
        }  else if ((message["graphValues"]) != nil) {
            NSLog("WC session: reply #graphValues")
            replyHandler(["reply" : self.getGraphValues(), "summary" : self.getGlanceValues()])
        }  else if ((message["stopAction"]) != nil) {
            NSLog("WC session: execute #stopAction")
            eyeHandler.endTrip()
        }  else if ((message["startAction"]) != nil) {
            NSLog("WC session: execute #startAction")
            eyeHandler.startTrip()
        }
    }
    
    @available(iOS 9.0, *)
    func sessionWatchStateDidChange(session: WCSession) {
        NSLog(#function)
        NSLog("\(session)")
        NSLog("reachable:\(session.reachable)")
    }
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?,
        reply: (([NSObject : AnyObject]?) -> Void)) {
            if ((userInfo?["glanceValues"]) != nil) {
                reply(self.getGlanceValues())
            } else if ((userInfo?["graphValues"]) != nil) {
                reply(["trip":"aaaa"])
            }
    }
    
    func initBTLE(){
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let channelIndex: Int = defaults.integerForKey("btleChannelIndex")
        let chan32: Int32 = Int32(channelIndex)
        TransferService.setValue(chan32);
        
        self.central.assignDataDelegate(self)
        self.central.startBluetooth()

    }

    @available(iOS 9.0, *)
    func initWCSession2() {
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self;
            session.activateSession()
            NSLog("WC session is activated")
        }
    }
    func initWCSession1() {
    }
    
    
    // ReceiverDelegate methods
    
    func strengthRSSI(RSSI: Int32) {
        // Signalstärke
    }
    
    func sendNotification(text:String){
        NSNotificationCenter.defaultCenter().postNotificationName("LogEvent", object: text)
    }
    func sendAlertNotification(text:String){
        NSNotificationCenter.defaultCenter().postNotificationName("AlertEvent", object: text)
    }
    func sendStartStopNotification(text:String){
        NSNotificationCenter.defaultCenter().postNotificationName("StartStopEvent", object: text)
    }
    
    
    func dataReceived(data: String) {
        var dataStringArr=data.characters.split{$0=="-"}.map { String($0) }
        var event: Event
        if dataStringArr[0]=="1"{
            switch dataStringArr[1]{
            case "0" :  event = EventGreen()
            case "1" :  event = EventOrange()
            case "2" :  event = EventRed()
            case "3" :  event = EventDarkRed()
            default :
                event = EventGreen()  //eigentlich gibt es nichts anderes
                return
            }
            let logText = eyeHandler.addEvent(event, delay:false)
            sendAlertNotification(dataStringArr[1])
            sendNotification(logText)
            NSLog(logText)
            
        }else if dataStringArr[0]=="42" {
            var logText = ""
            switch dataStringArr[1] {
            case "0":  eyeHandler.startTrip()
            logText = "StartTrip"
            case "1":  eyeHandler.endTrip()//eigentlich Pause
            logText = "EndTrip / Pause"
            dataStringArr[1] = "2"
            case "2":  eyeHandler.endTrip()
            logText = "EndTrip"
            default:
                NSLog("logText default")
            }
            sendStartStopNotification(dataStringArr[1])
            sendNotification(logText)
            NSLog(logText)
        }
    }
    
    func isRSSIAllowed(RSSI: Int32) -> Bool {
        
        return !(RSSI > -15 || RSSI < -270)
        /*        //if RSSI >- 15 {
         //  return false
         }
         if RSSI <- 270 {
         return false
         }
         return true;*/
    }
    
    func isConnected() {
        
    }
    
    func isDisconnected() {
        
    }
    
    
}

