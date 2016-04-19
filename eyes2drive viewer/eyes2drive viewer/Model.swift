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
        let neuerTrip = Trip();
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
    
    func hasTrips()->Bool {
        return trips.count > 0
    }
    
    func isStarted()->Bool {
        return hasTrips() && self.getCurrentTrip().isStarted()
    }
    
}

/*

list of events
    time    event
      0s    color, timestamp, duration = 0
    1.5s    color, timestamp, duration = 1.5s
    4.5s    color, timestamp, duration = 3s
    open    color, timestamp, duration = -1 (means calculated until now or endtrip)
*/

class Trip {
    var events = [Event]()
    let start: NSDate = NSDate()
    var end: NSDate = NSDate()
    var stopped = false
    
    init(){
        self.addEvent(EventGreen())
    }
    func stopTrip(){
        end = NSDate()
        stopped = true
        self.lastEvent().endNow()
    }
    func startTrip(){
        stopped = false
    }
    func lastEvent()->Event {
        return self.events[self.events.count-1];
    }
    func firstEvent()->Event {
        return self.events[0];
    }
    func addEvent(event:Event) {
        event.trip = self
        if (self.events.count > 0) {
            self.events.append(self.lastEvent().endWithEvent(event))
        } else {
            self.events.append(event)
        }
    }
    func generateDashboard()->Dashboard{
        return Dashboard(self)
    }
    func generateDashboardDetails()->DashboardDetails{
        return DashboardDetails(self)
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
    
    /* calculate the color total time with the help of a dashboard */
    func getDeltaTimeInMs(dashboard: Dashboard, inout _ g:Double, inout _ o:Double, inout _ r:Double) {
        for currentEvent : Event in self.events {
            dashboard.setMs(currentEvent, &g, &o, &r)
        }
    }

    func getEndTrip()->NSDate {
        if (self.stopped) {
            return self.end
        } else {
            return NSDate()
        }
    }
    func isStarted()->Bool {
        return !stopped
    }

}

class DashboardDetails: Dashboard {
    var eventData : Array<[String : AnyObject]> = Array<[String : AnyObject]>()
    override init(_ trip:Trip){
        super.init(trip)
    }
    override func setMs(event: Event, inout _ g:Double, inout _ o:Double, inout _ r:Double){
        super.setMs(event, &g, &o, &r)
        self.eventData.append(event.json())
    }
    override func json()->Array<[String : AnyObject]> {
        return self.eventData
    }

}


class Dashboard {
    var scoreInPercent = 0
    var greenDurationInPercent = 0
    var orangeDurationInPercent = 0
    var redDurationInPercent = 0
    var totalS = 0.0
    var trip: Trip;
    
    init(_ trip:Trip){
        var greenDurationInMs = 0.0
        var orangeDurationInMs = 0.0
        var redDurationInMs = 0.0
        self.trip = trip
        self.trip.getDeltaTimeInMs(self, &greenDurationInMs, &orangeDurationInMs, &redDurationInMs)
        self.calculateScoring(trip, greenDurationInMs, orangeDurationInMs, redDurationInMs)
        NSLog("total time in S = %d", self.totalS)
    }
    func calculateScoring (trip: Trip, _ greenDurationInMs:Double, _ orangeDurationInMs: Double, _ redDurationInMs:Double) {
        let deltaTotalMs = greenDurationInMs + orangeDurationInMs*3 + redDurationInMs*5
        if (deltaTotalMs > 0) {
            self.greenDurationInPercent = Int(greenDurationInMs / deltaTotalMs * 100)
            self.orangeDurationInPercent = Int(orangeDurationInMs / deltaTotalMs * 100)
            self.redDurationInPercent = Int(redDurationInMs / deltaTotalMs * 100)
            self.scoreInPercent = greenDurationInPercent + orangeDurationInPercent + redDurationInPercent
        }
        self.totalS = trip.durationInS()
    }

    func setMs(event: Event, inout _ g:Double, inout _ o:Double, inout _ r:Double){
        event.setMs(self, &g, &o, &r)
    }
    func json()->Array<[String : AnyObject]> {
        let score = NSNumber(integer: self.scoreInPercent)
        let green = NSNumber(integer: self.greenDurationInPercent)
        let orange = NSNumber(integer: self.orangeDurationInPercent)
        let red = NSNumber(integer: self.redDurationInPercent)
        let duration = NSNumber(double: self.totalS)
        let json = ["score":score, "green":green, "orange":orange, "red":red, "duration":duration, "isStarted" : self.trip.isStarted()]
        return Array<[String : AnyObject]>(arrayLiteral: json)
    }

}

class Event {
    var timestamp = NSDate()
    var logged = false;
    private var deltaInMs:Double = -1
    weak var trip: Trip?
    
    func getNotifcationBodyText()->String{
        return "This is a transparent message"
    }
    func shouldThrowNotification() -> Bool {
        return true;
    }
    func json()->[String : AnyObject] {
        return
            ["color": "none", "durationInMs":self.getDeltaTimeInMs()]
    }
    func jsonFromColor(color:String)->[String : AnyObject] {
        return
            ["color": color, "durationInMs":self.getDeltaTimeInMs(), "sinceStartInMs": self.getDeltaTimeSinceStartInMs()]
    }
    
    /* calculate the delta time of the current event, based on the new one */
    func endWithEvent(event:Event)->Event {
        self.deltaInMs = event.timestamp.timeIntervalSinceDate(self.timestamp)*1000
        return event
    }
    /* calculate the delta time of the current event, based on endTime of Trip */
    func endNow() {
        self.deltaInMs = (self.trip?.getEndTrip().timeIntervalSinceDate(self.timestamp))!*1000
    }
    func setMs(dashboard: Dashboard, inout _ g:Double, inout _ o:Double, inout _ r:Double){
    }
    func getDeltaTimeInMs()->Double {
        if (self.deltaInMs == -1) {
            return (self.trip?.getEndTrip().timeIntervalSinceDate(self.timestamp))!*1000
        } else {
            return self.deltaInMs
        }
    }
    func getDeltaTimeSinceStartInMs()->Double {
        return (self.timestamp.timeIntervalSinceDate((self.trip?.start)!))*1000
    }
    func showedInLog() {
        self.logged = true
    }
    func wasShownInLog()->Bool {
        return self.logged
    }
    func shouldShownInLog()->Bool {
        return !self.logged
    }
}

class EventGreen:Event{
    override func getNotifcationBodyText() -> String {
        return "Need some weeds - if you see this there is a bug or you see it in the debug-log :-)"
    }
    override func shouldThrowNotification() -> Bool {
        return false;
    }
    override func setMs(dashboard: Dashboard, inout _ g:Double, inout _ o:Double, inout _ r:Double) {
        g += self.getDeltaTimeInMs()
    }
    override func json()->[String : AnyObject] {
        return self.jsonFromColor("green")
    }

}

class EventOrange:Event{
    override func getNotifcationBodyText() -> String {
        return "huhu - are you alive? but don't look at the Watch while driving"
    }
    override func setMs(dashboard: Dashboard, inout _ g:Double, inout _ o:Double, inout _ r:Double){
        o += self.getDeltaTimeInMs()
    }
    override func json()->[String : AnyObject] {
        return self.jsonFromColor("orange")
    }
}

class EventRed:Event{
    override func getNotifcationBodyText() -> String {
        return "HEY !!! What's up? eyes 2 drive please"
    }
    override func setMs(dashboard: Dashboard, inout _ g:Double, inout _ o:Double, inout _ r:Double){
        r += self.getDeltaTimeInMs()
    }
    override func json()->[String : AnyObject] {
        return self.jsonFromColor("red")
    }
}

class EventDarkRed:Event{
    override func getNotifcationBodyText() -> String {
        return "Make a break - please! You are very distracted!"
    }
    override func setMs(dashboard: Dashboard, inout _ g:Double, inout _ o:Double, inout _ r:Double){
        r += self.getDeltaTimeInMs()
    }
    override func json()->[String : AnyObject] {
        return self.jsonFromColor("red")
    }
}
