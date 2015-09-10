//
//  SecondViewController.swift
//  eyes2drive viewer
//
//  Created by Lorenz Hänggi on 18/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func fireEvent(sender: AnyObject) {
        switch sender.selectedSegmentIndex{
        case 0:
            eyeHandler.addEvent(EventType.green)
        case 1:
            eyeHandler.addEvent(EventType.orange)
        case 2:
            eyeHandler.addEvent(EventType.red)
        default:
            eyeHandler.addEvent(EventType.green)
        };
        
    }
    
    
    @IBAction func fireStartStop(sender: AnyObject) {
        switch sender.selectedSegmentIndex{
        case 0:
            eyeHandler.startTrip()
        case 1:
            eyeHandler.endTrip()
        default:
            eyeHandler.startTrip()
        };
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

