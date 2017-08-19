//
//  MDJFirebaseConfigurerTests.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import XCTest
@testable import Jogger

class MDJFirebaseConfigurerTests: XCTestCase {
    var sut: MDJFirebaseConfigurer!

    var appMock: MDJFirebaseAppMock!

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        appMock = MDJFirebaseAppMock()

        sut = MDJDefaultFirebaseConfigurer(app: appMock)
    }
    
    // MARK: - Test Methods

    func test_configure_callsConfigureOnFirebaseApp() {
        // Arrange
        // Act
        sut.configure()

        // Assert
        XCTAssertTrue(appMock.didConfigure)
    }

    func test_configure_calledTwice_onlyCallsConfigureOnceOnFirebaseApp() {
        // Arrange
        sut.configure()
        appMock.didConfigure = false

        // Act
        sut.configure()

        // Assert
        XCTAssertFalse(appMock.didConfigure)
    }
}
