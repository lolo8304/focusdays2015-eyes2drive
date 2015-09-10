//
//  Model.swift
//  eyes2drive viewer
//
//  Created by Rémy Schumm on 10.09.15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import Foundation


class Trips {

    var trips = [Trip]();


}



class Trip {
    var events = [Event]();
    let start = NSDate();
    let end = NSDate();
    
    
    
}




class Event {
    var typ: EventType = EventType.green;
    
}


enum EventType {
    
    case green, orange, red
    
}
