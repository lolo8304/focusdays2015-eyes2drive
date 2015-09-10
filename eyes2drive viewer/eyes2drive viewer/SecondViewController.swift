//
//  SecondViewController.swift
//  eyes2drive viewer
//
//  Created by Lorenz Hänggi on 18/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController{
    
    var delay: Bool = false;

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func fireEvent(sender: AnyObject) {
        switch sender.selectedSegmentIndex{
        case 0:
            eyeHandler.addEvent(EventGreen(),delay: delay)
        case 1:
            eyeHandler.addEvent(EventOrange(),delay: delay)
        case 2:
            eyeHandler.addEvent(EventRed(),delay: delay)
        default:
            eyeHandler.addEvent(EventGreen(),delay:delay)
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
            delay = true
        } else {
            delay = false
        }
    }
    
    @IBOutlet weak var delaySwitch: UISwitch!

}

