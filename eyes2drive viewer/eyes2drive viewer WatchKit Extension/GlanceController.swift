//
//  GlanceController.swift
//  eyes2drive viewer
//
//  Created by Anton und Daniel on 10.09.15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class GlanceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var lblScoreInPercent: WKInterfaceLabel!
    @IBOutlet weak var lblGreenDurationInPercent: WKInterfaceLabel!
    @IBOutlet weak var lblOrangeDurationInPercent: WKInterfaceLabel!
    @IBOutlet weak var lblRedDurationInPercent: WKInterfaceLabel!
    
    @IBOutlet weak var lblTripDuration: WKInterfaceLabel!
    
    //interval timer
    var updateGlanceTimer = NSTimer()

    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            NSLog("WC session is activated")
        }
        updateGlanceTimer = NSTimer.scheduledTimerWithTimeInterval(1.0 ,
            target: self,
            selector: "updateGlance",
            userInfo: nil,
            repeats: true)

    }
    
    static func niceTimeString(time: Int)->String {
        let DAY_IN_S = 60*60*24
        let HOURS_IN_S = 60*60
        let MIN_IN_S = 60
        var t: Int = time
        
        if (t >= DAY_IN_S) {
            let days = t / DAY_IN_S
            
            t = t % DAY_IN_S
            let h = t / HOURS_IN_S
            
            t = t % HOURS_IN_S
            let min = t / MIN_IN_S
            
            t = t % MIN_IN_S
            let s = t
            
            return "\(days)d \(h)h \(min)m \(s)s"
        }
        if (t >= 60*60) {
            let h = t / HOURS_IN_S
            
            t = t % HOURS_IN_S
            let min = t / MIN_IN_S
            
            t = t % MIN_IN_S
            let s = t
            
            return "\(h)h \(min)m \(s)s"
        }
        if (t > 60) {
            let min = t / MIN_IN_S
            
            t = t % MIN_IN_S
            let s = t
            
            return "\(min)m \(s)s"
        }
        return "\(t)s"
    }
    
    
    func verifyIfDeviceIsRechableAndUnlocked()->Bool {
        if (!WCSession.defaultSession().reachable) {
            NSLog("WCsession: session is NOT reachable")
            if (WCSession.defaultSession().iOSDeviceNeedsUnlockAfterRebootForReachability) {
                self.lblTripDuration.setText("💤 wake up the phone!")
            }
            return false
        } else {
            NSLog("WCsession: session is reachable")
            self.lblTripDuration.setText("⌚️ 0s")
            return true
        }
    }
    
    func updateGlance() {
        NSLog("update glance data")
        if (!self.verifyIfDeviceIsRechableAndUnlocked()) { return }
        
        let applicationData = ["glanceValues":"yes"]
        WCSession.defaultSession().sendMessage(applicationData, replyHandler: {(reply: [String : AnyObject]) -> Void in
                NSLog("update glance: data received")
                if let score = reply["score"] as? NSNumber {
                    self.lblScoreInPercent.setText("\(score.integerValue)%")
                }
                if let green = reply["green"] as? NSNumber {
                    self.lblGreenDurationInPercent.setText("Green: \(green.integerValue)%")
                }
                if let orange = reply["orange"] as? NSNumber {
                    self.lblOrangeDurationInPercent.setText("Orange: \(orange.integerValue)%")
                }
                if let red = reply["red"] as? NSNumber {
                    self.lblRedDurationInPercent.setText("Red: \(red.integerValue)%")
                }
                if let duration = reply["duration"] as? NSNumber {
                    let durationString = GlanceController.niceTimeString(duration.integerValue)
                    self.lblTripDuration.setText("⌚️ \(durationString)")
                }
            }, errorHandler: {(error ) -> Void in
                NSLog("update glance: error \(error)")
        })
    }

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()

    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        updateGlanceTimer = NSTimer()
    }
    
    // =========================================================================
    // MARK: - WCSessionDelegate
    
    func sessionWatchStateDidChange(session: WCSession) {
        print(__FUNCTION__)
        print(session)
        print("reachable:\(session.reachable)")
    }
    
}
