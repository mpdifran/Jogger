//
//  MDJUserDatabaseObserverTests.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-26.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import XCTest
@testable import Jogger

class MDJUserDatabaseObserverTests: XCTestCase {
    var sut: MDJUserDatabaseObserver!

    var databaseReferenceMock: MDJDatabaseReferenceMock!

    let testUser1 = MDJJogUser(email: "user1@test.com", userID: "user1", role: .userManager)
    let testUser2 = MDJJogUser(email: "user2@test.com", userID: "user2", role: .admin)

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        databaseReferenceMock = MDJDatabaseReferenceMock()

        sut = MDJDefaultUserDatabaseObserver(databaseReference: databaseReferenceMock)
    }

    // MARK: - Test Methods

    func test_beginObservingUsers_setsUpObserver() {
        // Arrange
        let expectedPath = "/users"

        // Act
        sut.beginObservingUsers()

        // Assert
        XCTAssertTrue(databaseReferenceMock.didObserve)
        XCTAssertEqual(expectedPath, databaseReferenceMock.currentPath)
        XCTAssertEqual(MDJDataEventType.value, databaseReferenceMock.lastEventType)
    }

    func test_beginObservingUsers_newData_updatesUsersList() {
        // Arrange
        sut.beginObservingUsers()

        // Act
        databaseReferenceMock.lastSnapshotCompletion?(createSnapshot())

        // Assert
        XCTAssertEqual(2, sut.users.count)
        let user1 = sut.users.filter({ $0.userID == testUser1.userID }).first!
        let user2 = sut.users.filter({ $0.userID == testUser2.userID }).first!

        XCTAssertEqual(testUser1, user1)
        XCTAssertEqual(testUser2, user2)
    }

    func test_beginObervingUsers_newData_postsNotification() {
        // Arrange
        let _ = expectation(forNotification: Notification.Name.MDJUserDatabaseObserverUsersUpdated.rawValue, object: sut,
                            handler: nil)
        sut.beginObservingUsers()

        // Act
        databaseReferenceMock.lastSnapshotCompletion?(createSnapshot())

        // Assert
        waitForExpectations(timeout: 0, handler: nil)
    }

    func test_beginObservingUsers_alreadyObserving_tearsDownExistingObserver() {
        // Arrange
        sut.beginObservingUsers()

        // Act
        sut.beginObservingUsers()

        // Assert
        XCTAssertTrue(databaseReferenceMock.didRemoveObserver)
        XCTAssertEqual(databaseReferenceMock.observerHandle, databaseReferenceMock.lastHandle)
    }

    func test_beginObservingUsers_alreadyObserving_clearsExistingUsersList() {
        // Arrange
        sut.beginObservingUsers()
        databaseReferenceMock.lastSnapshotCompletion?(createSnapshot())

        // Act
        sut.beginObservingUsers()

        // Assert
        XCTAssertEqual(0, sut.users.count)
    }

    func test_deinit_tearsDownExistingObserver() {
        // Arrange
        sut.beginObservingUsers()

        // Act
        sut = nil

        // Assert
        XCTAssertTrue(databaseReferenceMock.didRemoveObserver)
        XCTAssertEqual(databaseReferenceMock.observerHandle, databaseReferenceMock.lastHandle)
    }

    // MARK: - Helper Methods

    func createSnapshot() -> MDJDataSnapshot {
        let data: [String : [AnyHashable : Any]] = [
            testUser1.userID : createDictionary(for: testUser1),
            testUser2.userID : createDictionary(for: testUser2)
        ]
        return MDJDataSnapshotMock(value: data)
    }

    func createDictionary(for user: MDJJogUser) -> [AnyHashable : Any] {
        return [MDJDatabaseConstants.Key.email : user.email,
                MDJDatabaseConstants.Key.role : user.role.rawValue]
    }
}
