//
//  MDJJogTests.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import XCTest
@testable import Jogger

class MDJJogTests: XCTestCase {
    var sut: MDJJog!

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        sut = MDJJog(date: Date(), distance: 10, time: 36000)
    }
    
    // MARK: - Test Methods
    
    func test_averageSpeed_returnsCorrectValue() {
        // Arrange
        // Act
        let result = sut.averageSpeed

        // Assert
        XCTAssertEqual(1, result)
    }

    func test_hours_returnsCorrectValue() {
        // Arrange
        sut.time = 3660

        // Act
        let result = sut.hours

        // Assert
        XCTAssertEqual(1, result)
    }

    func test_minutes_returnsCorrectValue() {
        // Arrange
        sut.time = 3660

        // Act
        let result = sut.minutes

        // Assert
        XCTAssertEqual(1, result)
    }
}
