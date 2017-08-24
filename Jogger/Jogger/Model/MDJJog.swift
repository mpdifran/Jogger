//
//  MDJJog.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-16.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation

// MARK: - MDJJog

class MDJJog {
    /// The identifier for the jog on the server.
    var identifier: String?

    /// The date of the beginning of the run.
    var date = Date()

    /// The distance of the run, in km.
    var distance: Double = 0

    /// The time of the run, in seconds.
    var time: TimeInterval = 0

    /// The number of complete hours in the run.
    var hours: TimeInterval {
        return floor(time / 3600)
    }

    /// The number of minutes after the last complete hour.
    var minutes: TimeInterval {
        let remainingTime = time.truncatingRemainder(dividingBy: 3600)
        return floor(remainingTime / 60)
    }

    /// The average speed, in km/h.
    var averageSpeed: Double {
        return distance / time * 3600
    }

    init() { }

    init(date: Date, distance: Double, time: TimeInterval) {
        self.date = date
        self.distance = distance
        self.time = time
    }
}
