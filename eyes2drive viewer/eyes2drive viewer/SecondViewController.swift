//
//  SecondViewController.swift
//  eyes2drive viewer
//
//  Created by Lorenz Hänggi on 18/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController{
    
    var delay: Int = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func fireEvent(sender: AnyObject) {
        switch sender.selectedSegmentIndex{
        case 0:
            eyeHandler.addEvent(EventGreen())
        case 1:
            eyeHandler.addEvent(EventOrange())
        case 2:
            eyeHandler.addEvent(EventRed())
        default:
            eyeHandler.addEvent(EventGreen())
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

    @IBAction func changeDelay(sender: AnyObject) {
        if delaySwitch.on {
            delay = 30
        } else {
            delay = 0
        }
    }
    
    @IBOutlet weak var delaySwitch: UISwitch!

}

