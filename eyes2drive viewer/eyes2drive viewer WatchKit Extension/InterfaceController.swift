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
    @IBOutlet var imageScoreGroup: WKInterfaceGroup!

    @IBOutlet var lblScore: WKInterfaceLabel!
    
    //interval timer
    var updateStatisticsTimer: NSTimer?
    var angle:Int = 0
    var images: [UIImage]! = []

    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if (WCSession.isSupported() && !WCSession.defaultSession().reachable) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            NSLog("WC session Graph is activated")
        }
        for (var i=0; i<=36; i++) {
            let name = "progress-\(i)"
            let image: UIImage? = UIImage(named: name)
            images.append(image!)
        }
    }
    
    func setImageToScore(score: Int) {
        var imageScore: Int = score
        if (imageScore > 100) { imageScore = 100 }
        if (imageScore < 0) { imageScore = 0 }
        let imageScore36 = 36 * imageScore / 100
        dispatch_async(dispatch_get_main_queue(), {
            self.imageScoreGroup.setBackgroundImage(self.images[imageScore36])
            self.lblScore.setText("\(imageScore)%")
        })
    }

    func nextPoint()->[String : CGFloat] {
        switch angle {
        case 0:  return ["x":0,"y":-50]
        case 1:  return ["x":50,"y":-50]
        case 2:  return ["x":50,"y":0]
        case 3:  return ["x":50,"y":50]
        case 4:  return ["x":0,"y":50]
        case 5:  return ["x":-50,"y":50]
        case 6:  return ["x":-50,"y":0]
        case 7:  return ["x":-50,"y":-50]
        default:
            return ["x":0, "y": 0]
        }
    }
    
    func showGraph(reply: [String : AnyObject]) {
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
        let x: CGFloat = 50
        let y: CGFloat = 50
        let next:[String : CGFloat] = self.nextPoint()
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, x+next["x"]!, y+next["y"]!);
        CGContextStrokePath(context);
        angle += 1
        if (angle >= 8) { angle = 0 }
        
        // Convert to UIImage
        let cgimage = CGBitmapContextCreateImage(context);
        let uiimage = UIImage(CGImage: cgimage!)
        
        // End the graphics context
        UIGraphicsEndImageContext()
        
        // Show on WKInterfaceImage
        graph.setImage(uiimage)
    }
    
    
    func showGraph() {
        if (self.updateStatisticsTimer == nil) {return}
        let applicationData = ["graphValues":"yes"]
        WCSession.defaultSession().sendMessage(applicationData,
            replyHandler: {
                [unowned self]
                (reply: [String : AnyObject]) -> Void in
                self.showGraph(reply)
            },
            errorHandler: {(error) -> Void in
                NSLog("error while getting graph values \(error)")
            }
        )
        //Holt von der Parent-App neue Daten - wird vom obigen NSTimer getriggert.
        //Siehe AppDelegate func application(application: UIApplication, handleWatchKitExtensionRequest....
        /* watch OS 1
        WKInterfaceController.openParentApplication(["graphValues":"yes"],
        reply: {(reply, error) -> Void in
        
        self.showGraph()
        /* write code here to add graph */
        
        })
        */
        
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        self.setImageToScore(68)
    }
    override func didAppear() {
        /*
        if self.updateStatisticsTimer == nil {
            self.updateStatisticsTimer = NSTimer.scheduledTimerWithTimeInterval(10.0,
                target: self,
                selector: "showGraph",
                userInfo: nil,
                repeats: true)
            NSLog("install graph timer")
        }
        */
    }
    override func willDisappear() {
        /*
        self.updateStatisticsTimer?.invalidate()
        self.updateStatisticsTimer = nil
        */
        NSLog("invalidate graph timer")
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        // especially when home-button is pressed, there is no #willDisappear
        /*
        if (self.updateStatisticsTimer != nil) {
            self.updateStatisticsTimer?.invalidate()
            self.updateStatisticsTimer = nil
            NSLog("invalidate graph timer")
        }
        */
        super.didDeactivate()
    }

}
