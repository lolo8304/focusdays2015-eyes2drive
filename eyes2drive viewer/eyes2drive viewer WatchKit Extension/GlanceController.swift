//
//  GlanceController.swift
//  eyes2drive viewer
//
//  Created by Anton und Daniel on 10.09.15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {
    
    @IBOutlet weak var lblScoreInPercent: WKInterfaceLabel!
    @IBOutlet weak var lblGreenDurationInPercent: WKInterfaceLabel!
    @IBOutlet weak var lblOrangeDurationInPercent: WKInterfaceLabel!
    @IBOutlet weak var lblRedDurationInPercent: WKInterfaceLabel!
    
    
    //interval timer
    var updateGlanceTimer = NSTimer()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        updateGlanceTimer = NSTimer.scheduledTimerWithTimeInterval(5.0 ,
            target: self,
            selector: "willActivate",
            userInfo: nil,
            repeats: true)
    
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        NSLog("Glance willActivate *********");
        
        WKInterfaceController.openParentApplication(["glanceValues":"yes"],
            reply: {(reply, error) -> Void in
                
                if let score = reply?["score"] as? NSNumber {
                    self.lblScoreInPercent.setText("\(score.integerValue)%")
                }
                if let green = reply?["green"] as? NSNumber {
                    self.lblGreenDurationInPercent.setText("Green: \(green.integerValue)%")
                }
                if let orange = reply?["orange"] as? NSNumber {
                    self.lblOrangeDurationInPercent.setText("Orange: \(orange.integerValue)%")
                }
                if let red = reply?["red"] as? NSNumber {
                    self.lblRedDurationInPercent.setText("Red: \(red.integerValue)%")
                }
        })
        
//        lblScoreInPercent.setText("\(score)%")
//        lblGreenDurationInPercent.setText("Green: \(green)%")
//        lblOrangeDurationInPercent.setText("Orange: \(orange)%")
//        lblRedDurationInPercent.setText("Red: \(red)%")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
