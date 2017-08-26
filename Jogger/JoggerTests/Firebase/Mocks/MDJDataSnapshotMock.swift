//
//  MDJDataSnapshotMock.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-26.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
@testable import Jogger

// MARK: - MDJDataSnapshotMock

class MDJDataSnapshotMock: MDJDataSnapshot {
    var value: Any?

    convenience init(value: Any?) {
        self.init()

        self.value = value
    }
}
