//
//  MDJJogReportDatabaseObserver.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-22.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation

// MARK: - Notifications

extension Notification.Name {
    static let MDJJogReportDatabaseObserverJogReportsUpdated =
        Notification.Name("Notification.Name.MDJJogReportDatabaseObserverJogReportsUpdated")
}

// MARK: - MDJJogReportDatabaseObserver

protocol MDJJogReportDatabaseObserver: class {
    var jogReports: [JogReport] { get }
}

// MARK: - MDJDefaultJogReportDatabaseObserver

class MDJDefaultJogReportDatabaseObserver {
    var jogReports = [JogReport]() {
        didSet {
            NotificationCenter.default.post(name: .MDJJogReportDatabaseObserverJogReportsUpdated, object: self)
        }
    }

    fileprivate let calendar = Calendar(identifier: .gregorian)
    fileprivate let workerQueue = DispatchQueue(label: "com.markdifranco.Jogger.MDJDefaultJogReportDatabaseObserver.queue")

    fileprivate let jogsObserver: MDJJogsDatabaseObserver

    init(jogsObserver: MDJJogsDatabaseObserver) {
        self.jogsObserver = jogsObserver
    }
}

// MARK: MDJJogReportDatabaseObserver Methods

extension MDJDefaultJogReportDatabaseObserver: MDJJogReportDatabaseObserver { }

// MARK: Private Methods

private extension MDJDefaultJogReportDatabaseObserver {

    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .MDJJogsDatabaseObserverJogsUpdated, object: jogsObserver,
                                               queue: .main) { [weak self] (_) in
                                                guard let jogs = self?.jogsObserver.jogs else { return }

                                                self?.workerQueue.async {
                                                    self?.updateReportsList(with: jogs)
                                                }
        }
    }

    func updateReportsList(with jogs: [Jog]) {
        var reports = [JogReport]()

        // Create a map of dates (representing the beginning of a week) to a list of jogs occurring in that week.
        let weekMap = jogsObserver.jogs.reduce([:]) { (map, jog) -> [Date : [Jog]] in
            guard let weekDate = createBeginningOfWeekDate(from: jog.date) else { return map }

            var mutableMap = map
            var jogs = mutableMap[weekDate] ?? []
            jogs.append(jog)
            mutableMap[weekDate] = jogs

            return mutableMap
        }

        // Sort the dates chronologically
        let sortedKeys = weekMap.keys.sorted(by: >)

        // Create the reports
        for weekDate in sortedKeys {
            guard let jogs = weekMap[weekDate] else { continue }

            let (averageSpeed, totalDistance) = calculateStatistics(for: jogs)

            reports.append(JogReport(date: weekDate, averageSpeed: averageSpeed, totalDistance: totalDistance))
        }

        DispatchQueue.main.async { [weak self] in
            self?.jogReports = reports
        }
    }

    /// Determines the average speed and total distance covered from the provided list of jogs.
    ///
    /// - parameter jogs: The jogs to determine statistics for.
    /// - returns: A tuple representing the average speed and total distance covered by the list of jogs.
    func calculateStatistics(for jogs: [Jog]) -> (averageSpeed: Double, totalDistance: Double) {
        let totalDistance = jogs.reduce(0) { $0 + $1.distance }
        let totalTime = jogs.reduce(0) { $0 + $1.time }
        let averageSpeed = totalDistance / totalTime

        return (averageSpeed: averageSpeed, totalDistance: totalDistance)
    }

    /// Creates a date representing the beginning-of-the-week for the given date.
    ///
    /// - parameter date: The date to determine the beginning-of-the-week date for.
    /// - returns: A date representing the beginning of the week for the provided date.s
    func createBeginningOfWeekDate(from date: Date) -> Date? {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        var startOfWeekComponents = DateComponents()

        startOfWeekComponents.weekOfYear = components.weekOfYear
        startOfWeekComponents.weekday = 1
        startOfWeekComponents.yearForWeekOfYear = components.yearForWeekOfYear

        return calendar.date(from: startOfWeekComponents)
    }
}
