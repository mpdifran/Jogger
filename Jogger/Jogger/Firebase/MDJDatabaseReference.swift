//
//  MDJDatabaseReference.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-16.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Swinject

typealias MDJDataEventType = DataEventType

// MARK: - MDJDatabaseReference

protocol MDJDatabaseReference: class {

    func child(_ pathString: String) -> MDJDatabaseReference
    func childByAutoId() -> MDJDatabaseReference
    func setValue(_ value: Any?)
    func removeValue()

    func observe(_ eventType: MDJDataEventType, with block: @escaping (MDJDataSnapshot) -> Void) -> UInt
    func removeObserver(withHandle handle: UInt)
}

// MARK: - DatabaseReference Extension

extension DatabaseReference: MDJDatabaseReference {

    func child(_ pathString: String) -> MDJDatabaseReference {
        return child(pathString) as DatabaseReference
    }

    func childByAutoId() -> MDJDatabaseReference {
        return childByAutoId() as DatabaseReference
    }

    func observe(_ eventType: MDJDataEventType, with block: @escaping (MDJDataSnapshot) -> Void) -> UInt {
        return observe(eventType) { (snapshot: DataSnapshot) in
            block(snapshot)
        }
    }
}

// MARK: - MDJDatabaseReferenceAssembly

class MDJDatabaseReferenceAssembly: Assembly {

    func assemble(container: Container) {
        container.register(MDJDatabaseReference.self, factory: { _ in
            return Database.database().reference()
        }).inObjectScope(.container)
    }
}
