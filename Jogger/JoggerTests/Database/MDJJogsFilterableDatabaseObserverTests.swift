//
//  MDJJogsFilterableDatabaseObserverTests.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-26.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import XCTest
@testable import Jogger

class MDJJogsFilterableDatabaseObserverTests: XCTestCase {
    var sut: MDJJogsFilterableDatabaseObserver!

    var jogsObserverMock: MDJJogsDatabaseObserverMock!

    var earlyJog: MDJJog!
    var currentJog: MDJJog!
    var lateJog: MDJJog!

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        jogsObserverMock = MDJJogsDatabaseObserverMock()

        sut = MDJDefaultJogsFilterableDatabaseObserver(jogsObserver: jogsObserverMock)

        let date = Date()
        earlyJog = MDJJog(date: date.addingTimeInterval(-3600), distance: 1, time: 3600)
        currentJog = MDJJog(date: date, distance: 1, time: 3600)
        lateJog = MDJJog(date: date.addingTimeInterval(3600), distance: 1, time: 3600)
    }
    
    // MARK: - Test Methods

    func test_jogs_jogsUpdated_filteredJogsAreUpdated() {
        // Arrange
        jogsObserverMock.jogs = [earlyJog, currentJog, lateJog]

        // Act
        NotificationCenter.default.post(name: .MDJJogsDatabaseObserverJogsUpdated, object: jogsObserverMock)

        // Assert
        XCTAssertEqual(3, sut.jogs.count)
        XCTAssertTrue(sut.jogs.contains(where: { $0 === earlyJog }))
        XCTAssertTrue(sut.jogs.contains(where: { $0 === currentJog }))
        XCTAssertTrue(sut.jogs.contains(where: { $0 === lateJog }))
    }

    func test_jogs_jogsUpdated_notificationIsPosted() {
        // Arrange
        let _ = expectation(forNotification: Notification.Name.MDJJogsFilterableDatabaseObserverJogsUpdated.rawValue,
                            object: sut, handler: nil)
        jogsObserverMock.jogs = [earlyJog, currentJog, lateJog]

        // Act
        NotificationCenter.default.post(name: .MDJJogsDatabaseObserverJogsUpdated, object: jogsObserverMock)

        // Assert
        waitForExpectations(timeout: 0, handler: nil)
    }

    func test_applyFilter_startDate_jogsAreFiltered() {
        // Arrange
        jogsObserverMock.jogs = [earlyJog, currentJog, lateJog]
        let startDate = currentJog.date.addingTimeInterval(-1800)

        // Act
        sut.applyFilter(startDate: startDate, endDate: nil)

        // Assert
        XCTAssertEqual(2, sut.jogs.count)
        XCTAssertTrue(sut.jogs.contains(where: { $0 === currentJog }))
        XCTAssertTrue(sut.jogs.contains(where: { $0 === lateJog }))
    }

    func test_applyFilter_endDate_jogsAreFiltered() {
        // Arrange
        jogsObserverMock.jogs = [earlyJog, currentJog, lateJog]
        let endDate = currentJog.date.addingTimeInterval(1800)

        // Act
        sut.applyFilter(startDate: nil, endDate: endDate)

        // Assert
        XCTAssertEqual(2, sut.jogs.count)
        XCTAssertTrue(sut.jogs.contains(where: { $0 === earlyJog }))
        XCTAssertTrue(sut.jogs.contains(where: { $0 === currentJog }))
    }

    func test_applyFilter_startAndEndDate_jogsAreFiltered() {
        // Arrange
        jogsObserverMock.jogs = [earlyJog, currentJog, lateJog]
        let startDate = currentJog.date.addingTimeInterval(-1800)
        let endDate = currentJog.date.addingTimeInterval(1800)

        // Act
        sut.applyFilter(startDate: startDate, endDate: endDate)

        // Assert
        XCTAssertEqual(1, sut.jogs.count)
        XCTAssertTrue(sut.jogs.contains(where: { $0 === currentJog }))
    }
}
