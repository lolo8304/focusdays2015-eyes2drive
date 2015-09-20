//
//  InterfaceController.swift
//  eyes2drive viewer WatchKit Extension
//
//  Created by Lorenz Hänggi on 18/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

/* help information

http://stackoverflow.com/questions/31256603/render-a-line-graph-on-apple-watch-using-watchos-2

and details in

https://github.com/shu223/watchOS-2-Sampler
and
https://github.com/shu223/watchOS-2-Sampler/blob/master/watchOS2Sampler%20WatchKit%20Extension/DrawPathsInterfaceController.swift


new WATCHOS2 connectivity
http://www.kristinathai.com/watchos-2-tutorial-using-sendmessage-for-instantaneous-data-transfer-watch-connectivity-1/


*/


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet weak var graph: WKInterfaceImage!

    
    //interval timer
    var updateGlanceTimer: NSTimer?
    var session : WCSession!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    func showGraph() {
        // Create a graphics context
        NSLog("*** showGraph")
        let size = CGSizeMake(100, 100)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup for the path appearance
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        let width:CGFloat = 4.0
        CGContextSetLineWidth(context, width)
        
        // Draw lines
        CGContextBeginPath (context);
        CGContextMoveToPoint(context, 0, 0);
        CGContextAddLineToPoint(context, 100, 100);
        CGContextMoveToPoint(context, 0, 100);
        CGContextAddLineToPoint(context, 100, 0);
        CGContextStrokePath(context);
        
        // Convert to UIImage
        let cgimage = CGBitmapContextCreateImage(context);
        let uiimage = UIImage(CGImage: cgimage!)
        
        // End the graphics context
        UIGraphicsEndImageContext()
        
        // Show on WKInterfaceImage
        graph.setImage(uiimage)
    }
    

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if updateGlanceTimer == nil {
            updateGlanceTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
                target: self,
                selector: "willActivate",
                userInfo: nil,
                repeats: true)
        }

        if (WCSession.isSupported() && session == nil) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        
        //Holt von der Parent-App neue Daten - wird vom obigen NSTimer getriggert.
        //Siehe AppDelegate func application(application: UIApplication, handleWatchKitExtensionRequest....
        /* watch OS 1
        WKInterfaceController.openParentApplication(["graphValues":"yes"],
            reply: {(reply, error) -> Void in
                
                self.showGraph()
                /* write code here to add graph */
                
        })
        */
        
        let applicationData = ["graphValues":"yes"]
        session.sendMessage(applicationData,
            replyHandler: {
                [unowned self]
                (_: [String : AnyObject]) -> Void in
                self.showGraph()
            },
            errorHandler: {(error ) -> Void in
                // do nothing
            }
        )
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        updateGlanceTimer?.invalidate()
        updateGlanceTimer = nil
    }

}
