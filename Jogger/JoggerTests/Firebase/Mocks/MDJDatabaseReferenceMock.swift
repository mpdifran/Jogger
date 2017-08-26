//
//  MDJDatabaseReferenceMock.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-26.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
@testable import Jogger

// MARK: - MDJDatabaseReferenceMock

class MDJDatabaseReferenceMock: MDJDatabaseReference {
    var currentPath = ""
    var observerHandle: UInt = 1
    let autoIDPath = "autoID"

    var lastValue: Any?
    var lastValues: [AnyHashable : Any]?
    var lastCompletion: ((Error?, MDJDatabaseReference) -> Void)?
    var lastEventType: MDJDataEventType?
    var lastSnapshotCompletion: ((MDJDataSnapshot) -> Void)?
    var lastHandle: UInt?

    var didSetValue = false
    var didUpdateChildValues = false
    var didRemoveValue = false
    var didObserve = false
    var didObserverSingleEvent = false
    var didRemoveObserver = false

    func child(_ pathString: String) -> MDJDatabaseReference {
        currentPath += "/" + pathString
        return self
    }

    func childByAutoId() -> MDJDatabaseReference {
        return child(autoIDPath)
    }

    func setValue(_ value: Any?, withCompletionBlock block: @escaping (Error?, MDJDatabaseReference) -> Void) {
        didSetValue = true
        lastValue = value
        lastCompletion = block
    }

    func updateChildValues(_ values: [AnyHashable : Any],
                           withCompletionBlock block: @escaping (Error?, MDJDatabaseReference) -> Void) {
        didUpdateChildValues = true
        lastValues = values
        lastCompletion = block
    }

    func removeValue(completionBlock block: @escaping (Error?, MDJDatabaseReference) -> Void) {
        didRemoveValue = true
        lastCompletion = block
    }

    func observe(_ eventType: MDJDataEventType, with block: @escaping (MDJDataSnapshot) -> Void) -> UInt {
        didObserve = true
        lastEventType = eventType
        lastSnapshotCompletion = block
        return observerHandle
    }

    func observeSingleEvent(of eventType: MDJDataEventType, with block: @escaping (MDJDataSnapshot) -> Void) {
        didObserverSingleEvent = true
        lastEventType = eventType
        lastSnapshotCompletion = block
    }

    func removeObserver(withHandle handle: UInt) {
        didRemoveObserver = true
        lastHandle = handle
    }
}
