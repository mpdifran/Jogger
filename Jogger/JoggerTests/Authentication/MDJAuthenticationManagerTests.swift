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

    let testEmail = "mark@test.com"
    let testPassword = "password"

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        authMock = MDJAuthMock()

        sut = MDJDefaultAuthenticationManager(auth: authMock)
    }

    // MARK: - Test Methods

    func test_createUser_passesCredentialsToAuth() {
        // Arrange
        // Act
        sut.createUser(withEmail: testEmail, password: testPassword) { (_) in }

        // Assert
        XCTAssertEqual(testEmail, authMock.lastEmail)
        XCTAssertEqual(testPassword, authMock.lastPassword)
        XCTAssertTrue(authMock.didCreateUser)
    }

    func test_createUser_encountersError_errorPassedToCompletion() {
        // Arrange
        let exp = expectation(description: "\(#function)")
        let expectedError = NSError(domain: "com.test", code: 1, userInfo: nil)
        sut.createUser(withEmail: testEmail, password: testPassword) { (error) in
            XCTAssertEqual(expectedError, error as NSError?)
            exp.fulfill()
        }

        // Act
        authMock.lastCompletion?(nil, expectedError)

        // Assert
        waitForExpectations(timeout: 0, handler: nil)
    }

    func test_signIn_passesCredentialsToAuth() {
        // Arrange
        // Act
        sut.signIn(withEmail: testEmail, password: testPassword) { (_) in }

        // Assert
        XCTAssertEqual(testEmail, authMock.lastEmail)
        XCTAssertEqual(testPassword, authMock.lastPassword)
        XCTAssertTrue(authMock.didSignIn)
    }

    func test_signIn_encountersError_delegateIsInformed() {
        // Arrange
        let exp = expectation(description: "\(#function)")
        let expectedError = NSError(domain: "com.test", code: 1, userInfo: nil)
        sut.signIn(withEmail: testEmail, password: testPassword) { (error) in
            XCTAssertEqual(expectedError, error as NSError?)
            exp.fulfill()
        }

        // Act
        authMock.lastCompletion?(nil, expectedError)

        // Assert
        waitForExpectations(timeout: 0, handler: nil)
    }

    func test_signOut_callsSignOutOnAuth() {
        // Arrange
        // Act
        let _ = sut.signOut()

        // Assert
        XCTAssertTrue(authMock.didSignOut)
    }

    func test_signOut_encountersError_delegateIsInformed() {
        // Arrange
        let expectedError = NSError(domain: "com.test", code: 1, userInfo: nil)
        authMock.errorToThrow = expectedError

        // Act
        let result = sut.signOut()

        // Assert
        XCTAssertEqual(expectedError, result as NSError?)
    }
}
