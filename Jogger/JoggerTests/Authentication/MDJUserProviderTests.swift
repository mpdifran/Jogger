//
//  MDJUserProviderTests.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-18.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import XCTest
@testable import Jogger

class MDJUserProviderTests: XCTestCase {
    var sut: MDJUserProvider!

    var authManager: MDJAuthenticationManager!
    var authMock: MDJAuthMock!
    var userMock: MDJUserMock!

    let testEmail = "mark@test.com"
    let testPassword = "password"

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        authMock = MDJAuthMock()
        userMock = MDJUserMock()

        let baseClass = MDJDefaultAuthenticationManager(auth: authMock)
        authManager = baseClass
        sut = baseClass
    }

    // MARK: - Test Methods

    func test_user_signInUserNotNil_userPropertyIsSet() {
        // Arrange
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(userMock, nil)

        // Act
        let result = sut.user

        // Assert
        XCTAssertTrue(userMock === result)
    }

    func test_user_signInUserNil_userPropertyIsSet() {
        // Arrange
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(nil, nil)

        // Act
        let result = sut.user

        // Assert
        XCTAssertNil(result)
    }

    func test_user_createAccountUserNotNil_userPropertyIsSet() {
        // Arrange
        authManager.createUser(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(userMock, nil)

        // Act
        let result = sut.user

        // Assert
        XCTAssertTrue(userMock === result)
    }

    func test_user_createAccountUserNil_userPropertyIsSet() {
        // Arrange
        authManager.createUser(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(nil, nil)

        // Act
        let result = sut.user

        // Assert
        XCTAssertNil(result)
    }

    func test_user_userIsSet_notificationIsPosted() {
        // Arrange
        let notificationString = Notification.Name.MDJUserProviderUserUpdated.rawValue
        let _ = expectation(forNotification: notificationString, object: sut, handler: nil)
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }

        // Act
        authMock.lastCompletion?(userMock, nil)

        // Assert
        waitForExpectations(timeout: 0, handler: nil)
    }
}
