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

    @IBAction func fireGreen(sender: AnyObject) {
        /*switch sender.selectedSegmentIndex{
            case 0:
            
        default:
            
        };*/
        eyeHandler.addEvent(EventType.green)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func setDelay(sender: AnyObject) {
        if delaySwitch.on {
            delay = 30
        } else {
            delay = 0
        }
    }
    
    @IBOutlet weak var delaySwitch: UISwitch!

}

