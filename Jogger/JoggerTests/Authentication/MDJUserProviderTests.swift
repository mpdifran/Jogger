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
    var userDatabaseMock: MDJUserDatabaseMock!
    var currentUserObserverMock: MDJCurrentUserDatabaseObserverMock!
    var userMock: MDJUserMock!
    var authenticatedUser: MDJAuthenticatedUser!

    let testEmail = "mark@test.com"
    let testPassword = "password"

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        authMock = MDJAuthMock()
        userDatabaseMock = MDJUserDatabaseMock()
        currentUserObserverMock = MDJCurrentUserDatabaseObserverMock()
        userMock = MDJUserMock()

        authenticatedUser = MDJAuthenticatedUser(user: userMock, role: .default, email: testEmail)

        let baseClass = MDJDefaultAuthenticationManager(auth: authMock, userDatabase: userDatabaseMock,
                                                        currentUserObserver: currentUserObserverMock)
        authManager = baseClass
        sut = baseClass
    }

    // MARK: - Test Methods

    func test_user_signInUserNil_userPropertyIsNil() {
        // Arrange
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(nil, nil)

        // Act
        let result = sut.user

        // Assert
        XCTAssertNil(result)
    }

    func test_user_signInUserNotNilAuthenticatedUserNil_userPropertyIsNil() {
        // Arrange
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(userMock, nil)
        userDatabaseMock.lastFetchAuthenticatedUserCompletion?(nil)

        // Act
        let result = sut.user

        // Assert
        XCTAssertNil(result)
    }

    func test_user_signInUserNotNilauthenticatedUserNotNil_userPropertyIsSet() {
        // Arrange
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(userMock, nil)
        userDatabaseMock.lastFetchAuthenticatedUserCompletion?(authenticatedUser)

        // Act
        let result = sut.user

        // Assert
        XCTAssertTrue(authenticatedUser === result)
    }

    func test_user_createAccountUserNil_userPropertyIsNil() {
        // Arrange
        authManager.createUser(withEmail: testEmail, password: testPassword, role: .default) { (_) in }
        authMock.lastCompletion?(nil, nil)

        // Act
        let result = sut.user

        // Assert
        XCTAssertNil(result)
    }

    func test_user_createAccountUserNotNilRegistrationFails_userPropertyIsNil() {
        // Arrange
        authManager.createUser(withEmail: testEmail, password: testPassword, role: .default) { (_) in }
        authMock.lastCompletion?(userMock, nil)
        userDatabaseMock.lastRegisterCompletion?(nil, nil)

        // Act
        let result = sut.user

        // Assert
        XCTAssertNil(result)
    }

    func test_user_createAccountUserNotNilRegistrationSucceeds_userPropertyIsSet() {
        // Arrange
        authManager.createUser(withEmail: testEmail, password: testPassword, role: .default) { (_) in }
        authMock.lastCompletion?(userMock, nil)
        userDatabaseMock.lastRegisterCompletion?(authenticatedUser, nil)

        // Act
        let result = sut.user

        // Assert
        XCTAssertTrue(authenticatedUser === result)
    }

    func test_user_userIsSet_notificationIsPosted() {
        // Arrange
        let notificationString = Notification.Name.MDJUserProviderUserUpdated.rawValue
        let _ = expectation(forNotification: notificationString, object: sut, handler: nil)
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(userMock, nil)

        // Act
        userDatabaseMock.lastFetchAuthenticatedUserCompletion?(authenticatedUser)

        // Assert
        waitForExpectations(timeout: 0, handler: nil)
    }

    func test_user_userIsSet_deletionObserverIsSetup() {
        // Arrange
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(userMock, nil)

        // Act
        userDatabaseMock.lastFetchAuthenticatedUserCompletion?(authenticatedUser)

        // Assert
        XCTAssertTrue(currentUserObserverMock.didBeginObservingDeletion)
        XCTAssertEqual(userMock.uid, currentUserObserverMock.lastUserID)
    }

    func test_deletionObserver_deletionTriggered_userIsSetToNil() {
        // Arrange
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(userMock, nil)
        userDatabaseMock.lastFetchAuthenticatedUserCompletion?(authenticatedUser)

        // Act
        currentUserObserverMock.lastOnDeletionBlock?()

        // Assert
        XCTAssertNil(sut.user)
    }

    func test_userIsSet_roleObserverIsSetup() {
        // Arrange
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(userMock, nil)

        // Act
        userDatabaseMock.lastFetchAuthenticatedUserCompletion?(authenticatedUser)

        // Assert
        XCTAssertTrue(currentUserObserverMock.didBeginObservingRole)
        XCTAssertEqual(userMock.uid, currentUserObserverMock.lastUserID)
    }

    func test_onRoleUpdatedObserver_roleUpdatedToNewValue_userIsUpdatedWithNewRole() {
        // Arrange
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(userMock, nil)
        userDatabaseMock.lastFetchAuthenticatedUserCompletion?(authenticatedUser)

        // Act
        currentUserObserverMock.lastOnRoleUpdatedBlock?(.admin)

        // Assert
        XCTAssertEqual(MDJUserRole.admin, sut.user?.role)
    }

    func test_onRoleUpdatedObserver_roleUpdatedToSameValue_notificationIsNotPosted() {
        // Arrange
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(userMock, nil)
        userDatabaseMock.lastFetchAuthenticatedUserCompletion?(authenticatedUser)
        let notificationObserver = NotificationObserver()
        notificationObserver.observeNotification(name: .MDJUserProviderUserUpdated, object: sut)

        // Act
        currentUserObserverMock.lastOnRoleUpdatedBlock?(.default)

        // Assert
        XCTAssertNil(notificationObserver.lastNotification)
    }

    func test_onRoleUpdatedObserver_roleUpdated_notificationIsPosted() {
        // Arrange
        authManager.signIn(withEmail: testEmail, password: testPassword) { (_) in }
        authMock.lastCompletion?(userMock, nil)
        userDatabaseMock.lastFetchAuthenticatedUserCompletion?(authenticatedUser)
        let notificationString = Notification.Name.MDJUserProviderUserUpdated.rawValue
        let _ = expectation(forNotification: notificationString, object: sut, handler: nil)

        // Act
        currentUserObserverMock.lastOnRoleUpdatedBlock?(.admin)

        // Assert
        waitForExpectations(timeout: 0, handler: nil)
    }
}
