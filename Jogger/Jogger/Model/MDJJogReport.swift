//
//  MDJJogReport.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-22.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation

// MARK: - MDJJogReport

class MDJJogReport {
    let date: Date
    let averageSpeed: Double
    let totalDistance: Double

    init(date: Date, averageSpeed: Double, totalDistance: Double) {
        self.date = date
        self.averageSpeed = averageSpeed
        self.totalDistance = totalDistance
    }
}
