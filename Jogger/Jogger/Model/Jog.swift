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
    let date: Date
    let distance: Double
    let time: TimeInterval

    init(date: Date, distance: Double, time: TimeInterval) {
        self.date = date
        self.distance = distance
        self.time = time
    }
}
