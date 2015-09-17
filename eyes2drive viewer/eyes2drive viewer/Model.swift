//
//  Model.swift
//  eyes2drive viewer
//
//  Created by Rémy Schumm on 10.09.15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import Foundation


class Trips {
    var trips: [Trip] = [Trip]()
    
    func startTrip(){
        var neuerTrip = Trip();
        trips.append(neuerTrip);
    }
    
    func stopTrip(){
        getCurrentTrip().stopTrip()
    }
    
    func getCurrentTrip() -> Trip{
        if (trips.count == 0) {
            startTrip()
        }
        return trips[trips.count-1]
    }
    
}

class Trip {
    var events = [Event]()
    let start: NSDate = NSDate()
    var end: NSDate = NSDate()
    var stopped = false
    
    init(){
        events.append(EventGreen())
    }
    func stopTrip(){
        end = NSDate()
        stopped = true
    }
    func addEvent(event:Event) {
        self.events.append(event)
    }
    func generateDashboard()->Dashboard{
        return Dashboard(trip:self)
    }
    func durationInS()->Double {
        var timeInS = 0.0
        if (self.stopped) {
            timeInS = (end.timeIntervalSinceDate(start))
        } else {
            timeInS = (NSDate().timeIntervalSinceDate(start))
        }
        return timeInS
    }
    func getEndTrip()->NSDate {
        if (self.stopped) {
            return self.end
        } else {
            return NSDate()
        }
    }
}

class Dashboard {
    var scoreInPercent = 0
    var greenDurationInPercent = 0
    var orangeDurationInPercent = 0
    var redDurationInPercent = 0
    var totalS = 0.0
    
    init(trip:Trip){
        var greenDurationInMs = 0.0
        var orangeDurationInMs = 0.0
        var redDurationInMs = 0.0
        var deltaTotalMs = 0.0
        var lastEvent:Event
        var currentEvent:Event?
        
        currentEvent = trip.events[0] // Green Event is the first Event as Base
        for i in 1..<trip.events.count {
            lastEvent = trip.events[i-1]
            currentEvent = trip.events[i]
            var deltaDurationInMs = (currentEvent!.timestamp.timeIntervalSinceDate(lastEvent.timestamp)*1000)
            lastEvent.setMs(&greenDurationInMs, &orangeDurationInMs, &redDurationInMs, deltaDurationInMs)
        }
        var deltaDurationInMs = (trip.getEndTrip().timeIntervalSinceDate(currentEvent!.timestamp)*1000)
        currentEvent!.setMs(&greenDurationInMs, &orangeDurationInMs, &redDurationInMs, deltaDurationInMs)
        
        deltaTotalMs = greenDurationInMs + orangeDurationInMs + redDurationInMs
        if (deltaTotalMs > 0) {
            greenDurationInPercent = Int(greenDurationInMs / deltaTotalMs * 100)
            orangeDurationInPercent = Int(orangeDurationInMs / deltaTotalMs * 100)
            redDurationInPercent = Int(redDurationInMs / deltaTotalMs * 100)
            scoreInPercent = greenDurationInPercent + orangeDurationInPercent / 2 + redDurationInPercent / 4
            //greenDurationInPercent=Int(greenDurationInMs)
            //orangeDurationInPercent=Int(orangeDurationInMs)
            //redDurationInPercent=Int(redDurationInMs)
        }
        self.totalS = trip.durationInS()
        NSLog("total time in S = %s", self.totalS)
    }
}

class Event {
    var timestamp = NSDate()
    func getNotifcationBodyText()->String{
        return "This is a transparent message"
    }
    func shouldThrowNotification() -> Bool {
        return true;
    }
    func setMs(inout g:Double, inout _ o:Double, inout _ r:Double, _ delta:Double){
    }
}

class EventGreen:Event{
    override func getNotifcationBodyText() -> String {
        return "Need some weeds - if you see this there is a bug!"
    }
    override func shouldThrowNotification() -> Bool {
        return false;
    }
    override func setMs(inout g:Double, inout _ o:Double, inout _ r:Double, _ delta:Double){
        g += delta
    }
}

class EventOrange:Event{
    override func getNotifcationBodyText() -> String {
        return "huhu - are you alive? but don't look at the Watch while driving"
    }
    override func setMs(inout g:Double, inout _ o:Double, inout _ r:Double, _ delta:Double){
        o += delta
    }
}

class EventRed:Event{
    override func getNotifcationBodyText() -> String {
        return "HEY !!! What's up? eyes 2 drive please"
    }
    override func setMs(inout g:Double, inout _ o:Double, inout _ r:Double, _ delta:Double){
        r += delta
    }
}
