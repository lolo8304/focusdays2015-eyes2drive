//
//  EyeEventHandler.swift
//  eyes2drive viewer
//
//  Created by Michael Spoerri on 10.09.15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import Foundation
import UIKit


let eyeHandler = EyeEventHandler()

class EyeEventHandler : EyeEventHandlerProtocol {
    
    var tripsRepo:Trips = Trips()
    
    func addEvent(type: Event, delay: Bool)->String{
        //NSLog("Event geschickt: ");
        tripsRepo.getCurrentTrip().addEvent(type)

        if (type.shouldThrowNotification()) {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
            let notification = UILocalNotification()
            notification.alertBody = type.getNotifcationBodyText()// text that will be displayed in the notification
            notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        
            var offsetSec = 0;
            if delay {
                offsetSec = 10;
            }
            let now = NSDate().dateByAddingTimeInterval(NSTimeInterval(offsetSec))
            notification.fireDate = now // todo item due date (when notification will be fired)
        
            notification.soundName = UILocalNotificationDefaultSoundName // play default sound
            notification.userInfo = ["UUID": 12345, ] // assign a unique identifier to the notification so that we can retrieve it later
            //notification.category = "redAlertWarning"
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
        return "Status changed : "+type.getNotifcationBodyText()
    }
    
    func startTrip(){
        tripsRepo.startTrip()
        
    }
    
    func endTrip(){
        tripsRepo.stopTrip()
        
    }
    func hasTrips()->Bool {
        return tripsRepo.hasTrips()
    }
    func getCurrentTrip()->Trip {
        return tripsRepo.getCurrentTrip()
    }
    func currentDashboard()->Dashboard {
        return getCurrentTrip().generateDashboard()
    }
    func currentDashboardDetails()->Dashboard {
        return getCurrentTrip().generateDashboardDetails()
    }
}