//
//  FirstViewController.swift
//  eyes2drive viewer
//
//  Created by Lorenz Hänggi on 18/07/15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//
// get appDelegate: http://stackoverflow.com/questions/24046164/how-do-i-get-a-reference-to-the-app-delegate-in-swift

import UIKit


class FirstViewController: UIViewController, ReceiverDelegate {

    var appDelegate: AppDelegate?
    var central = BTLECentral()
<<<<<<< HEAD
=======
    var secView:SecondViewController?
>>>>>>> fea53e86916b90fad83b728e9f153a78b566ae44

    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        self.central.assignDataDelegate(self)
        self.central.startBluetooth()
        secView = SecondViewController(nibName: nil, bundle: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func strengthRSSI(RSSI: Int32) {
          // Signalstärke
    }
    
    func sendNotification(text:String){
        
        NSNotificationCenter.defaultCenter().postNotificationName("LogEvent", object: text)
    }
    
    
    func dataReceived(data: String) {
        var dataStringArr=split(data){$0=="-"}
        var event: Event
        if dataStringArr[0]=="1"{
            switch dataStringArr[1]{
                case "0" :  event = EventGreen()
                case "1" :  event = EventOrange()
                case "2" :  event = EventRed()
                default : event = EventRed()  //eigentlich Dark Red

            }
            var logText = eyeHandler.addEvent(event, delay:false)
<<<<<<< HEAD
            sendNotification(logText)
=======
            secView!.addLogText(logText)
>>>>>>> fea53e86916b90fad83b728e9f153a78b566ae44
            NSLog(logText)

        }else if dataStringArr[0]=="42" {
            var logText = ""
            switch dataStringArr[1] {
            case "0":  eyeHandler.startTrip()
                        logText = "StartTrip"
            case "1":  eyeHandler.endTrip()//eigentlich Pause
                        logText = "EndTrip / Pause"
            case "2":  eyeHandler.endTrip()
                        logText = "EndTrip"
            default:
                NSLog("logText default")
            }
<<<<<<< HEAD
           sendNotification(logText)
=======
            secView!.addLogText(logText)
>>>>>>> fea53e86916b90fad83b728e9f153a78b566ae44
            NSLog(logText)
        }
    }

    func isRSSIAllowed(RSSI: Int32) -> Bool {

        return !(RSSI > -15 || RSSI < -270)
/*        //if RSSI >- 15 {
          //  return false
        }
        if RSSI <- 270 {
            return false
        }
        return true;*/
    }

    func isConnected() {

    }

    func isDisconnected() {

    }
}

