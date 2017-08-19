//
//  MDJFirebaseAppMock.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
@testable import Jogger

// MARK: - MDJFirebaseAppMock

class MDJFirebaseAppMock: MDJFirebaseApp {
    var didConfigure = false

    func configure() {
        didConfigure = true
    }
}
