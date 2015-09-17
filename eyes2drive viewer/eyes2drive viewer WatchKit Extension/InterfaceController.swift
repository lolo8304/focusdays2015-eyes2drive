//
//  InterfaceController.swift
//  eyes2drive viewer WatchKit Extension
//
//  Created by Lorenz Hänggi on 18/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import WatchKit
import Foundation

/* help information


http://stackoverflow.com/questions/31256603/render-a-line-graph-on-apple-watch-using-watchos-2

and details in

https://github.com/shu223/watchOS-2-Sampler
and
https://github.com/shu223/watchOS-2-Sampler/blob/master/watchOS2Sampler%20WatchKit%20Extension/DrawPathsInterfaceController.swift



*/


class InterfaceController: WKInterfaceController {
    @IBOutlet weak var graph: WKInterfaceImage!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    
    
    func showGraph() {
        // Create a graphics context
        let size = CGSizeMake(100, 100)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        // Setup for the path appearance
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextSetLineWidth(context, 4.0)
        
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
        //Holt von der Parent-App neue Daten - wird vom obigen NSTimer getriggert.
        //Siehe AppDelegate func application(application: UIApplication, handleWatchKitExtensionRequest....
        WKInterfaceController.openParentApplication(["graphValues":"yes"],
            reply: {(reply, error) -> Void in
                
                let trip = reply?["trip"] as? Trip
                
                self.showGraph()
                /* write code here to add graph */
                
        })

    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
