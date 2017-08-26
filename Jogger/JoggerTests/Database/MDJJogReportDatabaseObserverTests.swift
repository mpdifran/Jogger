//
//  MDJJogReportDatabaseObserverTests.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-26.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import XCTest
@testable import Jogger

class MDJJogReportDatabaseObserverTests: XCTestCase {
    var sut: MDJJogReportDatabaseObserver!

    var jogsObserverMock: MDJJogsDatabaseObserverMock!

    var testUserID = "testUserID"

    let calendar = Calendar(identifier: .gregorian)

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        jogsObserverMock = MDJJogsDatabaseObserverMock()

        sut = MDJDefaultJogReportDatabaseObserver(jogsObserver: jogsObserverMock)
    }
    
    // MARK: - Test Methods

    func test_beginObservingJogReports_beginsObservingJogs() {
        // Arrange
        // Act
        sut.beginObservingJogReports(forUserWithUserID: testUserID)

        // Assert
        XCTAssertTrue(jogsObserverMock.didBeginObservingJogs)
        XCTAssertEqual(testUserID, jogsObserverMock.lastUserID)
    }

    func test_jogReports_jogsUpdated_jogReportsGenerated() {
        // Arrange
        sut.beginObservingJogReports(forUserWithUserID: testUserID)

        let sundayDate = createDate(forDayInWeek: 1, weekOfYear: 14) // April 2
        let saturdayDate = createDate(forDayInWeek: 7, weekOfYear: 14) // April 8
        let endOfYearDate = createDate(forDayInWeek: 1, weekOfYear: 1, year: 2018) // Dec 31, 2017
        let startOfYearDate = createDate(forDayInWeek: 2, weekOfYear: 1, year: 2018) // Jan 1, 2018

        jogsObserverMock.jogs = [MDJJog(date: sundayDate, distance: 1, time: 3600),
                                 MDJJog(date: saturdayDate, distance: 5, time: 7200),
                                 MDJJog(date: endOfYearDate, distance: 4, time: 7200),
                                 MDJJog(date: startOfYearDate, distance: 5, time: 3600)]
        // Act
        NotificationCenter.default.post(name: .MDJJogsDatabaseObserverJogsUpdated, object: jogsObserverMock)

        // Assert
        // Allow the background processing to run.
        let _ = expectation(forNotification: Notification.Name.MDJJogReportDatabaseObserverJogReportsUpdated.rawValue,
                            object: sut, handler: nil)
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertEqual(2, sut.jogReports.count)
        let firstReport = sut.jogReports.first
        let secondReport = sut.jogReports.last

        XCTAssertEqual(createBeginningOfWeekDate(from: endOfYearDate), firstReport?.date)
        XCTAssertEqual(3, firstReport?.averageSpeed)
        XCTAssertEqual(9, firstReport?.totalDistance)

        XCTAssertEqual(createBeginningOfWeekDate(from: sundayDate), secondReport?.date)
        XCTAssertEqual(2, secondReport?.averageSpeed)
        XCTAssertEqual(6, secondReport?.totalDistance)
    }

    func test_jogReports_jogReportsUpdated_notificationPosted() {
        // Arrange
        let _ = expectation(forNotification: Notification.Name.MDJJogReportDatabaseObserverJogReportsUpdated.rawValue,
                            object: sut, handler: nil)
        sut.beginObservingJogReports(forUserWithUserID: testUserID)

        // Act
        NotificationCenter.default.post(name: .MDJJogsDatabaseObserverJogsUpdated, object: jogsObserverMock)

        // Assert
        waitForExpectations(timeout: 1, handler: nil)
    }

    // MARK: - Helper Methods

    func createDate(forDayInWeek dayInWeek: Int = 1, weekOfYear: Int = 1, year: Int = 2017) -> Date {
        var dateComponents = DateComponents()
        dateComponents.weekOfYear = weekOfYear
        dateComponents.weekday = dayInWeek
        dateComponents.yearForWeekOfYear = year
        return calendar.date(from: dateComponents)!
    }

    func createBeginningOfWeekDate(from date: Date) -> Date? {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        var startOfWeekComponents = DateComponents()

        startOfWeekComponents.weekOfYear = components.weekOfYear
        startOfWeekComponents.weekday = 1
        startOfWeekComponents.yearForWeekOfYear = components.yearForWeekOfYear

        return calendar.date(from: startOfWeekComponents)
    }
}
