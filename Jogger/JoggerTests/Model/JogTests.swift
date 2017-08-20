//
//  JogTests.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import XCTest
@testable import Jogger

class JogTests: XCTestCase {
    var sut: Jog!

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        sut = Jog(date: Date(), distance: 10, time: 36000)
    }
    
    // MARK: - Test Methods
    
    func test_averageSpeed_returnsCorrectValue() {
        // Arrange
        // Act
        let result = sut.averageSpeed

        // Assert
        XCTAssertEqual(1, result)
    }
}
