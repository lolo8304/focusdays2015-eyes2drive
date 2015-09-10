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
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        /*
        var dashboard = Dashboard(trip: Trip());
        var score = dashboard.scoreInPercent
        var green = dashboard.greenDurationInPercent
        var orange = dashboard.orangeDurationInPercent
        var red = dashboard.redDurationInPercent
        */
        
        
        var score = 77
        var green = 85
        var orange = 14
        var red = 1
        
        lblScoreInPercent.setText("\(score)%")
        lblGreenDurationInPercent.setText("Green: \(green)%")
        lblOrangeDurationInPercent.setText("Orange: \(orange)%")
        lblRedDurationInPercent.setText("Red: \(red)%")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
