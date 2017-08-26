//
//  MDJJogsDatabaseObserverTests.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-26.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import XCTest
@testable import Jogger

class MDJJogsDatabaseObserverTests: XCTestCase {
    var sut: MDJJogsDatabaseObserver!

    var databaseReferenceMock: MDJDatabaseReferenceMock!

    let testUserID = "TestUserIdentifier"
    let firstJog = MDJJog(date: Date(), distance: 1, time: 3600)
    let secondJog = MDJJog(date: Date(), distance: 2, time: 7200)

    let dateFormatter = MDJDateFormatter()

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        databaseReferenceMock = MDJDatabaseReferenceMock()

        sut = MDJDefaultJogsDatabaseObserver(databaseReference: databaseReferenceMock)
    }
    
    // MARK: - Test Methods

    func test_beginObserving_setsUpObserver() {
        // Arrange
        let expectedPath = "/jogs/\(testUserID)"

        // Act
        sut.beginObservingJogs(forUserWithUserID: testUserID)

        // Assert
        XCTAssertTrue(databaseReferenceMock.didObserve)
        XCTAssertEqual(expectedPath, databaseReferenceMock.currentPath)
        XCTAssertEqual(MDJDataEventType.value, databaseReferenceMock.lastEventType)
    }

    func test_beginObserving_newData_updatesJogsList() {
        // Arrange
        sut.beginObservingJogs(forUserWithUserID: testUserID)

        // Act
        databaseReferenceMock.lastSnapshotCompletion?(createSnapshot())

        // Assert
        XCTAssertEqual(2, sut.jogs.count)
        let jog1 = sut.jogs.filter({ $0.identifier == "first" }).first!
        let jog2 = sut.jogs.filter({ $0.identifier == "second" }).first!

        XCTAssertEqual(1, jog1.distance)
        XCTAssertEqual(3600, jog1.time)
        let dateString1 = dateFormatter.string(from: jog1.date)
        let expectedDateString1 = dateFormatter.string(from: firstJog.date)
        XCTAssertEqual(expectedDateString1, dateString1)

        XCTAssertEqual(2, jog2.distance)
        XCTAssertEqual(7200, jog2.time)
        let dateString2 = dateFormatter.string(from: jog2.date)
        let expectedDateString2 = dateFormatter.string(from: secondJog.date)
        XCTAssertEqual(expectedDateString2, dateString2)
    }

    func test_beginObserving_newData_postsNotification() {
        // Arrange
        let _ = expectation(forNotification: Notification.Name.MDJJogsDatabaseObserverJogsUpdated.rawValue, object: sut,
                            handler: nil)
        sut.beginObservingJogs(forUserWithUserID: testUserID)

        // Act
        databaseReferenceMock.lastSnapshotCompletion?(createSnapshot())

        // Assert
        waitForExpectations(timeout: 0, handler: nil)
    }

    func test_beginObserving_alreadyObserving_tearsDownExistingObserver() {
        // Arrange
        sut.beginObservingJogs(forUserWithUserID: testUserID)

        // Act
        sut.beginObservingJogs(forUserWithUserID: testUserID + "2")

        // Assert
        XCTAssertTrue(databaseReferenceMock.didRemoveObserver)
        XCTAssertEqual(databaseReferenceMock.observerHandle, databaseReferenceMock.lastHandle)
    }

    func test_beginObserving_alreadyObserving_clearsExistingJogsList() {
        // Arrange
        sut.beginObservingJogs(forUserWithUserID: testUserID)
        databaseReferenceMock.lastSnapshotCompletion?(createSnapshot())

        // Act
        sut.beginObservingJogs(forUserWithUserID: testUserID + "2")

        // Assert
        XCTAssertEqual(0, sut.jogs.count)
    }

    func test_deinit_tearsDownExistingObserver() {
        // Arrange
        sut.beginObservingJogs(forUserWithUserID: testUserID)

        // Act
        sut = nil

        // Assert
        XCTAssertTrue(databaseReferenceMock.didRemoveObserver)
        XCTAssertEqual(databaseReferenceMock.observerHandle, databaseReferenceMock.lastHandle)
    }

    // MARK: - Helper Methods

    func createSnapshot() -> MDJDataSnapshot {
        let data: [String : [AnyHashable : Any]] = [
            "first" : createDictionary(for: firstJog),
            "second" : createDictionary(for: secondJog)
        ]
        return MDJDataSnapshotMock(value: data)
    }

    func createDictionary(for jog: MDJJog) -> [AnyHashable : Any] {
        return [MDJDatabaseConstants.Key.date : dateFormatter.string(from: jog.date),
                MDJDatabaseConstants.Key.distance : jog.distance,
                MDJDatabaseConstants.Key.time : jog.time]
    }
}
