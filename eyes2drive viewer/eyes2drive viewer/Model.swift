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
    let events = [Event]()
    let start = NSDate()
    var end = NSDate()
    
    func stopTrip(){
        end = NSDate()
    }
    
}

class Event {
    var typ: EventType = EventType.green;
    let timestamp = NSDate();
}

enum EventType {
    case green, orange, red
}
