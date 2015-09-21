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

class GlanceController1: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var lblScoreInPercent: WKInterfaceLabel!
    @IBOutlet weak var lblGreenDurationInPercent: WKInterfaceLabel!
    @IBOutlet weak var lblOrangeDurationInPercent: WKInterfaceLabel!
    @IBOutlet weak var lblRedDurationInPercent: WKInterfaceLabel!
    
    @IBOutlet weak var lblTripDuration: WKInterfaceLabel!
    
    //interval timer
    var updateGlanceTimer: NSTimer?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        if #available(iOSApplicationExtension 9.0, *) {
            if (WCSession.isSupported()) {
                let session = WCSession.defaultSession()
                session.delegate = self
                session.activateSession()
                NSLog("WC session is activated")
            }
        } else {
            // Fallback on earlier versions
        }
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
        if #available(iOSApplicationExtension 9.0, *) {
            if (!WCSession.defaultSession().reachable) {
                NSLog("WCsession: session is NOT reachable")
                self.lblTripDuration.setText("💤 wake up the phone!")
                return false
            } else {
                NSLog("WCsession: session is reachable")
                //            self.lblTripDuration.setText("⌚️ 0s")
                return true
            }
        } else {
            /* if not iOS9 */
            return true
        }
    }

    
    func updateLabels(reply: [String : AnyObject]) {
        NSLog("update glance: data received")
        if let score = reply["score"] as? NSNumber {
            self.lblScoreInPercent.setText("\(score.integerValue)%")
        }
        if let green = reply["green"] as? NSNumber {
            self.lblGreenDurationInPercent.setText("🍏 \(green.integerValue)%")
        }
        if let orange = reply["orange"] as? NSNumber {
            self.lblOrangeDurationInPercent.setText("🍊 \(orange.integerValue)%")
        }
        if let red = reply["red"] as? NSNumber {
            self.lblRedDurationInPercent.setText("🍎 \(red.integerValue)%")
        }
        if let duration = reply["duration"] as? NSNumber {
            let durationString = GlanceController1.niceTimeString(duration.integerValue)
            self.lblTripDuration.setText("⌚️ \(durationString)")
        }
    }
    
    
    func updateGlance() {
        if #available(iOSApplicationExtension 9.0, *) {
            self.updateGlance2()
        } else {
            self.updateGlance1()
        }
    }

    //Holt von der Parent-App neue Daten - wird vom obigen NSTimer getriggert.
    //Siehe AppDelegate func application(application: UIApplication, handleWatchKitExtensionRequest....
    /* watchOS1 interface */

    func updateGlance1() {
        NSLog("update whatchOS1 glance data")

        WKInterfaceController.openParentApplication(["glanceValues":"yes"],
            reply: {(reply, error) -> Void in
                if ((error) != nil) {
                    NSLog("update glance whatchOS1: error \(error)")
                } else {
                    self.updateLabels(reply as! [String : AnyObject])
                }
        })
    }

    @available(iOSApplicationExtension 9.0, *)
    func updateGlance2() {
        NSLog("update whatchOS2 glance data")
        if (!self.verifyIfDeviceIsRechableAndUnlocked()) { return }
        
        let applicationData = ["glanceValues":"yes"]
        WCSession.defaultSession().sendMessage(applicationData,
            replyHandler: {
                [unowned self]
                (reply: [String : AnyObject]) -> Void in
                self.updateLabels(reply)
            },
            errorHandler: {(error ) -> Void in
                NSLog("update glance whatchOS2: error \(error)")
            }
        )
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if updateGlanceTimer == nil {
            updateGlanceTimer = NSTimer.scheduledTimerWithTimeInterval(1.0 ,
                target: self,
                selector: "updateGlance",
                userInfo: nil,
                repeats: true)
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        updateGlanceTimer?.invalidate()
        updateGlanceTimer = nil
    }
    
    // =========================================================================
    // MARK: - WCSessionDelegate
    
    @available(iOSApplicationExtension 9.0, *)
    func sessionWatchStateDidChange(session: WCSession) {
        print(__FUNCTION__)
        print(session)
        print("reachable:\(session.reachable)")
    }
    
}
