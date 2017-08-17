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

// MARK: - MDJDatabaseReference

protocol MDJDatabaseReference: class {

    func child(_ pathString: String) -> MDJDatabaseReference
    func childByAutoId() -> MDJDatabaseReference
    func setValue(_ value: Any?)
    func removeValue()
}

// MARK: - DatabaseReference Extension

extension DatabaseReference: MDJDatabaseReference {

    func child(_ pathString: String) -> MDJDatabaseReference {
        return child(pathString) as DatabaseReference
    }

    func childByAutoId() -> MDJDatabaseReference {
        return childByAutoId() as DatabaseReference
    }
}

// MARK: - MDJDatabaseReferenceAssembly

class MDJDatabaseReferenceAssembly: Assembly {

    func assemble(container: Container) {
        container.register(MDJDatabaseReference.self) { _ in
            return Database.database().reference()
        }
    }
}
