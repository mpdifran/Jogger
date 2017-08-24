//
//  MDJUserDeletionDatabaseObserver.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-24.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration

// MARK: - MDJUserDeletionDatabaseObserver

protocol MDJUserDeletionDatabaseObserver: class {

    func beginObservingUserDeletion(forUserWithUserID userID: String, onDeletion: @escaping () -> Void)
}

// MARK: - MDJDefaultUserDeletionDatabaseObserver

class MDJDefaultUserDeletionDatabaseObserver {
    fileprivate let databaseReference: MDJDatabaseReference
    fileprivate var handle: UInt?

    init(databaseReference: MDJDatabaseReference) {
        self.databaseReference = databaseReference
    }

    deinit {
        tearDownObserver()
    }
}

// MARK: MDJUserDeletionDatabaseObserver Methods

extension MDJDefaultUserDeletionDatabaseObserver: MDJUserDeletionDatabaseObserver {

    func beginObservingUserDeletion(forUserWithUserID userID: String, onDeletion: @escaping () -> Void) {
        tearDownObserver()

        let path = MDJDatabaseConstants.Path.users(forUserID: userID)
        handle = databaseReference.child(path).observe(.childRemoved) { (snapshot) in
            onDeletion()
        }
    }
}

// MARK: Private Methods

private extension MDJDefaultUserDeletionDatabaseObserver {

    func tearDownObserver() {
        if let handle = handle {
            databaseReference.removeObserver(withHandle: handle)
        }
        handle = nil
    }
}

// MARK: - MDJUserDeletionDatabaseObserverAssembly

class MDJUserDeletionDatabaseObserverAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(MDJUserDeletionDatabaseObserver.self,
                               initializer: MDJDefaultUserDeletionDatabaseObserver.init)
    }
}
