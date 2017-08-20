//
//  Jog.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-16.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation

// MARK: - Jog

class Jog {
    var identifier: String?
    var date = Date()
    var distance: Double = 0
    var time: TimeInterval = 0

    var hours: TimeInterval {
        return floor(time / 3600)
    }
    var minutes: TimeInterval {
        let remainingTime = time.truncatingRemainder(dividingBy: 3600)
        return floor(remainingTime / 60)
    }

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
