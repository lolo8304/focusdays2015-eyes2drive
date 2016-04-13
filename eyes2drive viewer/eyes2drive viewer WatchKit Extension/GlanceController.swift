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
    
    @IBOutlet var groupScoreInPercent: WKInterfaceGroup?
    
    @IBOutlet weak var lblScoreInPercent: WKInterfaceLabel?
    @IBOutlet var imageScoreInPercent: WKInterfaceImage?
    @IBOutlet weak var lblGreenDurationInPercent: WKInterfaceLabel?
    @IBOutlet weak var lblOrangeDurationInPercent: WKInterfaceLabel?
    @IBOutlet weak var lblRedDurationInPercent: WKInterfaceLabel?
    
    @IBOutlet weak var lblTripDuration: WKInterfaceLabel?
    @IBOutlet weak var lblTripState: WKInterfaceLabel?
    
    //interval timer
    var updateGlanceTimer: NSTimer?
    var images: [UIImage]! = []
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            NSLog("WC session Glance is activated")
        }
        
        for (var i=0; i<=36; i = i + 1) {
            images.append(UIImage(named: "progress-\(i)")!)
        }
    }
    
    func setImageToScore(score: Int) {
        var imageScore: Int = score
        if (imageScore > 100) { imageScore = 100 }
        if (imageScore < 0) { imageScore = 0 }
        imageScore = 36 * imageScore / 100
        dispatch_async(dispatch_get_main_queue(), {
            self.imageScoreInPercent?.setImage(self.images[imageScore])
            self.groupScoreInPercent?.setBackgroundImage(self.images[imageScore])
        })
    }
    
    static func niceTimeString(time: Int, _ hhmmss:Bool = false)->String {
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
            if (hhmmss) {
                return String(format: "%02d:%02d:%02d", h, min, s)
            } else {
                return "\(days)d \(h)h \(min)m \(s)s"
            }
        }
        if (t >= 60*60) {
            let h = t / HOURS_IN_S
            
            t = t % HOURS_IN_S
            let min = t / MIN_IN_S
            
            t = t % MIN_IN_S
            let s = t
            
            if (hhmmss) {
                return String(format: "%02d:%02d:%02d", h, min, s)
            } else {
                return "\(h)h \(min)m \(s)s"
            }
        }
        if (t > 60) {
            let min = t / MIN_IN_S
            
            t = t % MIN_IN_S
            let s = t
            if (hhmmss) {
                return String(format: "%02d:%02d:%02d", 0, min, s)
            } else {
                return "\(min)m \(s)s"
            }
        }
        if (hhmmss) {
            return String(format: "%02d:%02d:%02d", 0, 0, t)
        } else {
            return "\(t)s"
        }
    }
    
    
    func verifyIfDeviceIsRechableAndUnlocked()->Bool {
        if (!WCSession.defaultSession().reachable) {
            NSLog("WCsession Glance is NOT reachable")
            if (WCSession.defaultSession().iOSDeviceNeedsUnlockAfterRebootForReachability) {
                self.lblTripDuration?.setText("💤 wake up the phone!")
            }
            return false
        } else {
            return true
        }
    }
    
    func updateGlance() {
        if (!self.verifyIfDeviceIsRechableAndUnlocked()) { return }
        
        let applicationData = ["glanceValues":"yes"]
        WCSession.defaultSession().sendMessage(applicationData,
            replyHandler: {
                [unowned self]
                (reply: [String : AnyObject]) -> Void in
                
                NSLog("update glance: data received")
                if let score = reply["score"] as? NSNumber {
                    self.lblScoreInPercent?.setText("\(score.integerValue)%")
                    self.setImageToScore(score.integerValue)
                }
                if let green = reply["green"] as? NSNumber {
                    self.lblGreenDurationInPercent?.setText("🍏 \(green.integerValue)%")
                }
                if let orange = reply["orange"] as? NSNumber {
                    self.lblOrangeDurationInPercent?.setText("🍊 \(orange.integerValue)%")
                }
                if let red = reply["red"] as? NSNumber {
                    self.lblRedDurationInPercent?.setText("🍎 \(red.integerValue)%")
                }
                if let duration = reply["duration"] as? NSNumber {
                    let durationString = GlanceController.niceTimeString(duration.integerValue)
                    self.lblTripDuration?.setText("⌚️ \(durationString)")
                }
                let isStarted = reply["isStarted"] as? Bool
                if (isStarted != nil && isStarted!) {
                    self.lblTripState?.setText("running")
                } else {
                    self.lblTripState?.setText("stopped")
                }
            },
            errorHandler: {(error ) -> Void in
                NSLog("update glance: error \(error)")
                self.endGlanceUpdates()
            }
        )
    }

    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }
    override func didAppear() {
        if updateGlanceTimer == nil {
            updateGlanceTimer = NSTimer.scheduledTimerWithTimeInterval(1.0 ,
                target: self,
                selector: #selector(GlanceController.updateGlance),
                userInfo: nil,
                repeats: true)
            NSLog("install Glance timer")
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    override func willDisappear() {
        updateGlanceTimer?.invalidate()
        updateGlanceTimer = nil
        NSLog("invalidate Glance timer")
    }
    
    // =========================================================================
    // MARK: - WCSessionDelegate
    
    func sessionWatchStateDidChange(session: WCSession) {
        print(#function, "reachable:\(session.reachable)")
    }
    
}
