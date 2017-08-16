//
//  MDJAuthenticationManagerTests.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-15.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import XCTest
@testable import Jogger

class MDJAuthenticationManagerTests: XCTestCase {
    var sut: MDJAuthenticationManager!

    var authMock: MDJAuthMock!
    var delegateMock: MDJAuthenticationManagerDelegateMock!

    let testEmail = "mark@test.com"
    let testPassword = "password"

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        authMock = MDJAuthMock()
        delegateMock = MDJAuthenticationManagerDelegateMock()

        sut = MDJDefaultAuthenticationManager(auth: authMock)
        sut.delegate = delegateMock
    }

    // MARK: - Test Methods

    func test_createUser_passesCredentialsToAuth() {
        // Arrange
        // Act
        sut.createUser(withEmail: testEmail, password: testPassword)

        // Assert
        XCTAssertEqual(testEmail, authMock.lastEmail)
        XCTAssertEqual(testPassword, authMock.lastPassword)
        XCTAssertTrue(authMock.didCreateUser)
    }

    func test_createUser_encountersError_delegateIsInformed() {
        // Arrange
        let expectedError = NSError(domain: "com.test", code: 1, userInfo: nil)
        sut.createUser(withEmail: testEmail, password: testPassword)

        // Act
        authMock.lastCompletion?(nil, expectedError)

        // Assert
        XCTAssertEqual(expectedError, delegateMock.lastError as NSError?)
    }

    func test_signIn_passesCredentialsToAuth() {
        // Arrange
        // Act
        sut.signIn(withEmail: testEmail, password: testPassword)

        // Assert
        XCTAssertEqual(testEmail, authMock.lastEmail)
        XCTAssertEqual(testPassword, authMock.lastPassword)
        XCTAssertTrue(authMock.didSignIn)
    }

    func test_signIn_encountersError_delegateIsInformed() {
        // Arrange
        let expectedError = NSError(domain: "com.test", code: 1, userInfo: nil)
        sut.signIn(withEmail: testEmail, password: testPassword)

        // Act
        authMock.lastCompletion?(nil, expectedError)

        // Assert
        XCTAssertEqual(expectedError, delegateMock.lastError as NSError?)
    }

    func test_signOut_callsSignOutOnAuth() {
        // Arrange
        // Act
        sut.signOut()

        // Assert
        XCTAssertTrue(authMock.didSignOut)
    }

    func test_signOut_encountersError_delegateIsInformed() {
        // Arrange
        let expectedError = NSError(domain: "com.test", code: 1, userInfo: nil)
        authMock.errorToThrow = expectedError

        // Act
        sut.signOut()

        // Assert
        XCTAssertEqual(expectedError, delegateMock.lastError as NSError?)
    }
}
