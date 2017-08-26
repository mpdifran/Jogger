//
//  MDJUserDeletionDatabaseObserverTests.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-26.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import XCTest
@testable import Jogger

class MDJUserDeletionDatabaseObserverTests: XCTestCase {
    var sut: MDJUserDeletionDatabaseObserver!

    var databaseReferenceMock: MDJDatabaseReferenceMock!

    let testUserID = "testUserID"

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        databaseReferenceMock = MDJDatabaseReferenceMock()

        sut = MDJDefaultUserDeletionDatabaseObserver(databaseReference: databaseReferenceMock)
    }
    
    // MARK: - Test Methods

    func test_beginObservingUserDeletion_setsupObserver() {
        // Arrange
        let expectedPath = "/users/\(testUserID)"

        // Act
        sut.beginObservingUserDeletion(forUserWithUserID: testUserID) { }

        // Assert
        XCTAssertTrue(databaseReferenceMock.didObserve)
        XCTAssertEqual(expectedPath, databaseReferenceMock.currentPath)
        XCTAssertEqual(MDJDataEventType.childRemoved, databaseReferenceMock.lastEventType)
    }

    func test_beginObservingUserDeletion_userDeleted_onDeletionBlockIsCalled() {
        // Arrange
        let exp = expectation(description: "\(#function)")
        sut.beginObservingUserDeletion(forUserWithUserID: testUserID) { 
            exp.fulfill()
        }

        // Act
        databaseReferenceMock.lastSnapshotCompletion?(MDJDataSnapshotMock())

        // Assert
        waitForExpectations(timeout: 0, handler: nil)
    }

    func test_beginObservingUserDeletion_alreadyObserving_tearsDownExistingObserver() {
        // Arrange
        sut.beginObservingUserDeletion(forUserWithUserID: testUserID) { }

        // Act
        sut.beginObservingUserDeletion(forUserWithUserID: testUserID) { }

        // Assert
        XCTAssertTrue(databaseReferenceMock.didRemoveObserver)
        XCTAssertEqual(databaseReferenceMock.observerHandle, databaseReferenceMock.lastHandle)
    }

    func test_deinit_tearsDownExistingObserver() {
        // Arrange
        sut.beginObservingUserDeletion(forUserWithUserID: testUserID) { }

        // Act
        sut = nil

        // Assert
        XCTAssertTrue(databaseReferenceMock.didRemoveObserver)
        XCTAssertEqual(databaseReferenceMock.observerHandle, databaseReferenceMock.lastHandle)
    }
}
