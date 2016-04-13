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

    @IBOutlet weak var startStopSegment: UISegmentedControl!
    @IBOutlet weak var eventSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(SecondViewController.onLogEvent(_:)),
            name: "LogEvent",
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(SecondViewController.onStartStopEvent(_:)),
            name: "StartStopEvent",
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(SecondViewController.onAlertEvent(_:)),
            name: "AlertEvent",
            object: nil)
        
    }
    
    func onLogEvent(notification: NSNotification){
        let text = notification.object as! String
        addLogText(text)
    }
    func onStartStopEvent(notification: NSNotification){
        let event = notification.object as! String
        if (event == "0") { // stop
            self.startStopSegment.selectedSegmentIndex = 0
        } else { //start
            self.startStopSegment.selectedSegmentIndex = 1
        }
    }
    func onAlertEvent(notification: NSNotification){
        let event = notification.object as! String
        self.eventSegment.selectedSegmentIndex = Int(event)!
    }

    @IBAction func fireEvent(sender: AnyObject) {
        var logText = ""
        switch sender.selectedSegmentIndex{
        case 0:
            logText = eyeHandler.addEvent(EventGreen(),delay: delay)
        case 1:
            logText = eyeHandler.addEvent(EventOrange(),delay: delay)
        case 2:
            logText = eyeHandler.addEvent(EventRed(),delay: delay)
        case 3:
            logText = eyeHandler.addEvent(EventDarkRed(),delay: delay)
        default:
            logText = eyeHandler.addEvent(EventGreen(),delay:delay)
        };
        NSLog(logText)
        addLogText(logText)
    }
    
    
    @IBOutlet weak var logUI: UITextView!

    func addLogText(text:String){
        if ((logUI) != nil) {
            logUI.text = text + "\n" + logUI.text
        }
    }
    
    
    @IBAction func fireStartStop(sender: AnyObject) {
        var logText = ""
        
        switch sender.selectedSegmentIndex{
        case 0:
            eyeHandler.startTrip()
            logText = "App started"
        case 1:
            eyeHandler.endTrip()
            logText = "App stopped"
        default:
            eyeHandler.startTrip()
            logText = "Error, default Case"
        };
        NSLog(logText); 
        addLogText(logText)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeDelay(sender: AnyObject) {
        var logText = ""
        if delaySwitch.on {
            delay = true
           logText = "Set Delay : true "
        } else {
            delay = false
            logText="Set Delay : false"
        }
        NSLog(logText)
        addLogText(logText)
    }
    
    @IBOutlet weak var delaySwitch: UISwitch!

}

