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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        self.central.assignDataDelegate(self)
        self.central.startBluetooth()
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
    func sendAlertNotification(text:String){
        NSNotificationCenter.defaultCenter().postNotificationName("AlertEvent", object: text)
    }
    func sendStartStopNotification(text:String){
        NSNotificationCenter.defaultCenter().postNotificationName("StartStopEvent", object: text)
    }
    
    
    func dataReceived(data: String) {
        var dataStringArr=data.characters.split{$0=="-"}.map { String($0) }
        var event: Event
        if dataStringArr[0]=="1"{
            switch dataStringArr[1]{
                case "0" :  event = EventGreen()
                case "1" :  event = EventOrange()
                case "2" :  event = EventRed()
                case "3" :  event = EventDarkRed()
                default :
                    event = EventGreen()  //eigentlich gibt es nichts anderes
                    return
            }
            let logText = eyeHandler.addEvent(event, delay:false)
            sendAlertNotification(dataStringArr[1])
            sendNotification(logText)
            NSLog(logText)

        }else if dataStringArr[0]=="42" {
            var logText = ""
            switch dataStringArr[1] {
            case "0":  eyeHandler.startTrip()
                        logText = "StartTrip"
            case "1":  eyeHandler.endTrip()//eigentlich Pause
                        logText = "EndTrip / Pause"
                        dataStringArr[1] = "2"
            case "2":  eyeHandler.endTrip()
                        logText = "EndTrip"
            default:
                NSLog("logText default")
            }
            sendStartStopNotification(dataStringArr[1])
            sendNotification(logText)
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

