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
        var greenDurationInMs = 0
        var orangeDurationInMs = 0
        var redDurationInMs = 0
        var lastEventTs = trip.start
        var totalMs = 0
        
        for event in trip.events {
            var durationInMs:Int = Int(event.timestamp.timeIntervalSinceDate(lastEventTs))
            event.setMs(&greenDurationInMs, &orangeDurationInMs, &redDurationInMs, durationInMs)
            lastEventTs = event.timestamp
        }
        
        totalMs = greenDurationInMs + orangeDurationInMs + redDurationInMs
        if (totalMs > 0) {
            greenDurationInPercent = greenDurationInMs / totalMs * 100
            orangeDurationInPercent = orangeDurationInMs / totalMs * 100
            redDurationInPercent = redDurationInMs / totalMs * 100
            scoreInPercent = greenDurationInPercent + orangeDurationInPercent / 2 + redDurationInPercent / 4
        }
    }
}

class Event {
    var timestamp = NSDate()
    func getColor()->String{
        return "white"
    }
    func setMs(inout g:Int, inout _ o:Int, inout _ r:Int, _ delta:Int){
    }
}

class EventGreen:Event{
    override func getColor() -> String {
        return "green"
    }
    override func setMs(inout g:Int, inout _ o:Int, inout _ r:Int, _ delta:Int){
        g += delta
    }
}

class EventOrange:Event{
    override func getColor() -> String {
        return "orange"
    }
    override func setMs(inout g:Int, inout _ o:Int, inout _ r:Int, _ delta:Int){
        o += delta
    }
}

class EventRed:Event{
    override func getColor() -> String {
        return "red"
    }
    override func setMs(inout g:Int, inout _ o:Int, inout _ r:Int, _ delta:Int){
        r += delta
    }
}
