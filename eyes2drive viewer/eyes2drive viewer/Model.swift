//
//  Model.swift
//  eyes2drive viewer
//
//  Created by Rémy Schumm on 10.09.15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import Foundation


class Trips {
    var trips: [Trip] = [Trip]();

    
    func startAndAddNewTrip(){
        var neuerTrip = Trip();
        trips.append(neuerTrip);
    }
    
    func stopCurrentTrip(){
        getCurrentTrip().stopTrip()
    }
    
    func getCurrentTrip() -> Trip{
        if (trips.count == 0) {
            startAndAddNewTrip()
        }
        return trips[trips.count-1]
    }
    
}

class Trip {
    var events = [Event]()
    let start = NSDate()
    var end = NSDate()
    init(){
        events.append(EventGreen())
    }
    func stopTrip(){
        end = NSDate()
    }
    func addEvent(event:Event) {
        self.events.append(event)
    }
    func generateDashboard()->Dashboard{
        return Dashboard(trip:self)
    }
}

class Dashboard {
    var scoreInPercent = 0
    var greenDurationInPercent = 0
    var orangeDurationInPercent = 0
    var redDurationInPercent = 0
    
    init(trip:Trip){
        var greenDurationInMs = 0.0
        var orangeDurationInMs = 0.0
        var redDurationInMs = 0.0
        var totalMs = 0.0
        var lastEvent:Event
        var currentEvent:Event?
        var durationInMs:Double
        
        for i in 1..<trip.events.count {
            lastEvent = trip.events[i-1]
            currentEvent = trip.events[i]
            durationInMs = (currentEvent!.timestamp.timeIntervalSinceDate(lastEvent.timestamp)*1000)
            lastEvent.setMs(&greenDurationInMs, &orangeDurationInMs, &redDurationInMs, durationInMs)
        }
        if trip.events.count > 1 {
            durationInMs = (NSDate().timeIntervalSinceDate(currentEvent!.timestamp)*1000)
            currentEvent!.setMs(&greenDurationInMs, &orangeDurationInMs, &redDurationInMs, durationInMs)
        }
        
        totalMs = greenDurationInMs + orangeDurationInMs + redDurationInMs
        if (totalMs > 0) {
            greenDurationInPercent = Int(greenDurationInMs / totalMs * 100)
            orangeDurationInPercent = Int(orangeDurationInMs / totalMs * 100)
            redDurationInPercent = Int(redDurationInMs / totalMs * 100)
            scoreInPercent = greenDurationInPercent + orangeDurationInPercent / 2 + redDurationInPercent / 4
            //greenDurationInPercent=Int(greenDurationInMs)
            //orangeDurationInPercent=Int(orangeDurationInMs)
            //redDurationInPercent=Int(redDurationInMs)
        }
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
