//
//  MDJUserDeletionDatabaseObserverMock.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-25.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
@testable import Jogger

// MARK: - MDJUserDeletionDatabaseObserverMock

class MDJUserDeletionDatabaseObserverMock: MDJUserDeletionDatabaseObserver {

    var lastUserID: String?
    var lastOnDeletionBlock: (() -> Void)?

    var didBeginObserving = false


    func beginObservingUserDeletion(forUserWithUserID userID: String, onDeletion: @escaping () -> Void) {
        lastUserID = userID
        lastOnDeletionBlock = onDeletion

        didBeginObserving = true
    }
}
