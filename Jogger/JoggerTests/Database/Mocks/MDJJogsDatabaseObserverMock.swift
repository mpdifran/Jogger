//
//  MDJJogsDatabaseObserverMock.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-26.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
@testable import Jogger

// MARK: - MDJJogsDatabaseObserverMock

class MDJJogsDatabaseObserverMock: MDJJogsDatabaseObserver {
    var jogs = [MDJJog]()

    var lastUserID: String?
    var didBeginObservingJogs = false

    func beginObservingJogs(forUserWithUserID userID: String) {
        didBeginObservingJogs = true
        lastUserID = userID
    }
}
