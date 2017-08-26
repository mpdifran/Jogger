//
//  MDJJogsDatabaseTests.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-26.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import XCTest
@testable import Jogger

class MDJJogsDatabaseTests: XCTestCase {
    var sut: MDJJogsDatabase!

    var databaseReferenceMock: MDJDatabaseReferenceMock!

    var testJog: MDJJog!
    let testUserIdentifier = "TestUserIdentifier"
    let dateFormatter = MDJDateFormatter()

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        databaseReferenceMock = MDJDatabaseReferenceMock()

        testJog = MDJJog(date: Date(), distance: 14, time: 3660)

        sut = MDJDefaultJogsDatabase(databaseReference: databaseReferenceMock)
    }

    // MARK: - Test Methods

    func test_createOrUpdateJog_noServerIdentifier_createsNewJog() {
        // Arrange
        testJog.identifier = nil
        let expectedPath = "/jogs/\(testUserIdentifier)/\(databaseReferenceMock.autoIDPath)"

        // Act
        sut.createOrUpdate(jog: testJog, forUserID: testUserIdentifier) { (_) in }

        // Assert
        XCTAssertTrue(databaseReferenceMock.didSetValue)
        XCTAssertEqual(expectedPath, databaseReferenceMock.currentPath)
        XCTAssertTrue(databaseReferenceMock.lastValue is [AnyHashable : Any])
        guard let value = databaseReferenceMock.lastValue as? [AnyHashable : Any] else { return }

        XCTAssertEqual(dateFormatter.string(from: testJog.date), value[MDJDatabaseConstants.Key.date] as? String)
        XCTAssertEqual(testJog.distance, value[MDJDatabaseConstants.Key.distance] as? Double)
        XCTAssertEqual(testJog.time, value[MDJDatabaseConstants.Key.time] as? TimeInterval)
    }

    func test_createOrUpdateJog_noServerIdentifierAndErrorEncountered_errorPassedToCompletion() {
        // Arrange
        testJog.identifier = nil
        let exp = expectation(description: "\(#function)")
        let expectedError = NSError(domain: "com.test", code: 1, userInfo: nil)
        sut.createOrUpdate(jog: testJog, forUserID: testUserIdentifier) { (error) in
            XCTAssertEqual(expectedError, error as NSError?)
            exp.fulfill()
        }

        // Act
        databaseReferenceMock.lastCompletion?(expectedError, databaseReferenceMock)

        // Assert
        waitForExpectations(timeout: 0, handler: nil)
    }

    func test_createOrUpdateJog_serverIdentifier_createsNewJog() {
        // Arrange
        testJog.identifier = "jogIdentifier"
        let expectedPath = "/jogs/\(testUserIdentifier)/jogIdentifier"

        // Act
        sut.createOrUpdate(jog: testJog, forUserID: testUserIdentifier) { (_) in }

        // Assert
        XCTAssertTrue(databaseReferenceMock.didSetValue)
        XCTAssertEqual(expectedPath, databaseReferenceMock.currentPath)
        XCTAssertTrue(databaseReferenceMock.lastValue is [AnyHashable : Any])
        guard let value = databaseReferenceMock.lastValue as? [AnyHashable : Any] else { return }

        XCTAssertEqual(dateFormatter.string(from: testJog.date), value[MDJDatabaseConstants.Key.date] as? String)
        XCTAssertEqual(testJog.distance, value[MDJDatabaseConstants.Key.distance] as? Double)
        XCTAssertEqual(testJog.time, value[MDJDatabaseConstants.Key.time] as? TimeInterval)
    }

    func test_createOrUpdateJog_serverIdentifierAndErrorEncountered_errorPassedToCompletion() {
        // Arrange
        testJog.identifier = "jogIdentifier"
        let exp = expectation(description: "\(#function)")
        let expectedError = NSError(domain: "com.test", code: 1, userInfo: nil)
        sut.createOrUpdate(jog: testJog, forUserID: testUserIdentifier) { (error) in
            XCTAssertEqual(expectedError, error as NSError?)
            exp.fulfill()
        }

        // Act
        databaseReferenceMock.lastCompletion?(expectedError, databaseReferenceMock)

        // Assert
        waitForExpectations(timeout: 0, handler: nil)
    }

    func test_delete_noServerID_doesNotCallDatabase() {
        // Arrange
        testJog.identifier = nil

        // Act
        sut.delete(jog: testJog, forUserID: testUserIdentifier) { (_) in }

        // Assert
        XCTAssertFalse(databaseReferenceMock.didRemoveValue)
    }

    func test_delete_serverID_removesJog() {
        // Arrange
        testJog.identifier = "jogIdentifier"
        let expectedPath = "/jogs/\(testUserIdentifier)/jogIdentifier"

        // Act
        sut.delete(jog: testJog, forUserID: testUserIdentifier) { (_) in }

        // Assert
        XCTAssertTrue(databaseReferenceMock.didRemoveValue)
        XCTAssertEqual(expectedPath, databaseReferenceMock.currentPath)
    }

    func test_delete_serverIDAndErrorEncountered_errorPassedToCompletion() {
        // Arrange
        testJog.identifier = "jogIdentifier"
        let exp = expectation(description: "\(#function)")
        let expectedError = NSError(domain: "com.test", code: 1, userInfo: nil)
        sut.delete(jog: testJog, forUserID: testUserIdentifier) { (error) in
            XCTAssertEqual(expectedError, error as NSError?)
            exp.fulfill()
        }

        // Act
        databaseReferenceMock.lastCompletion?(expectedError, databaseReferenceMock)

        // Assert
        waitForExpectations(timeout: 0, handler: nil)
    }

    // MARK: - Helper Methods

    func createDictionaryRepresentation(for jog: MDJJog) -> [AnyHashable : Any] {
        return [MDJDatabaseConstants.Key.date : dateFormatter.string(from: jog.date),
                MDJDatabaseConstants.Key.distance : jog.distance,
                MDJDatabaseConstants.Key.time : jog.time]
    }
}
