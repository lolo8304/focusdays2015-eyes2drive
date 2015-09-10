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
        return trips[trips.count]
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
    let scoreInPercent:Int
    let greenDurationInPercent:Int
    let orangeDurationInPercent:Int
    let redDurationInPercent:Int
    
    init(trip:Trip){
        var greenDurationInMs:Int=0
        var orangeDurationInMs:Int=0
        var redDurationInMs:Int=0
        var lastEventTs:NSDate=trip.start
        var totalMs:Int
        
        for event in trip.events {
            var durationInMs:Int = Int(event.timestamp.timeIntervalSinceDate(lastEventTs))
            event.setMs(&greenDurationInMs, &orangeDurationInMs, &redDurationInMs, durationInMs)
            lastEventTs = event.timestamp
        }
        
        totalMs = greenDurationInMs + orangeDurationInMs + redDurationInMs
        greenDurationInPercent = greenDurationInMs / totalMs * 100
        orangeDurationInPercent = orangeDurationInMs / totalMs * 100
        redDurationInPercent = redDurationInMs / totalMs * 100
        
        scoreInPercent = 95
    }
}

class Event {
    let timestamp = NSDate()
    func setMs(inout g:Int, inout _ o:Int, inout _ r:Int, _ delta:Int){
    }
}

class EventGreen:Event{
    override func setMs(inout g:Int, inout _ o:Int, inout _ r:Int, _ delta:Int){
        g += delta
    }
}

class EventOrange:Event{
    override func setMs(inout g:Int, inout _ o:Int, inout _ r:Int, _ delta:Int){
        o += delta
    }
}

class EventRed:Event{
    override func setMs(inout g:Int, inout _ o:Int, inout _ r:Int, _ delta:Int){
        r += delta
    }
}

enum EventType {
    case green, orange, red
}
