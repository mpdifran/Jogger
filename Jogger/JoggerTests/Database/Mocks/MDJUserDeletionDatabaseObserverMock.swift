//
//  MDJCurrentUserDatabaseObserverMock.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-25.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
@testable import Jogger

// MARK: - MDJCurrentUserDatabaseObserverMock

class MDJCurrentUserDatabaseObserverMock: MDJCurrentUserDatabaseObserver {
    var lastUserID: String?
    var lastOnRoleUpdatedBlock: ((MDJUserRole) -> Void)?
    var lastOnDeletionBlock: (() -> Void)?

    var didBeginObservingRole = true
    var didBeginObservingDeletion = false

    func beginObservingUserRole(forUserWithID userID: String, onRoleUpdated: @escaping (MDJUserRole) -> Void) {
        lastUserID = userID
        lastOnRoleUpdatedBlock = onRoleUpdated

        didBeginObservingRole = true
    }

    func beginObservingUserDeletion(forUserWithUserID userID: String, onDeletion: @escaping () -> Void) {
        lastUserID = userID
        lastOnDeletionBlock = onDeletion

        didBeginObservingDeletion = true
    }
}
