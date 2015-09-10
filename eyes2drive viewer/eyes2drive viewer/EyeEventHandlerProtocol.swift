//
//  EyeEventHandlerProtocol.swift
//  eyes2drive viewer
//
//  Created by Michael Spoerri on 10.09.15.
//  Copyright (c) 2015 Focusdays2015. All rights reserved.
//

import Foundation

protocol EyeEventHandlerProtocol {

    func addEvent(type: Event, delay:Bool)

    func startTrip()

    func endTrip()

}
