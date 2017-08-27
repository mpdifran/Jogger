//
//  MDJCurrentUserDatabaseObserver.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-24.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration

// MARK: - MDJCurrentUserDatabaseObserver

protocol MDJCurrentUserDatabaseObserver: class {

    /// Begin observing changes to the role for a specific user.
    ///
    /// - note: This will fail unless the currently authenticated user is a user manager or an admin.
    ///
    /// - parameter userID: The identifier of the user to observe role changes for.
    /// - parameter onRoleUpdated: A block that is called whenever the user's role updates.
    /// - parameter role: The user's new role.
    func beginObservingUserRole(forUserWithID userID: String, onRoleUpdated: @escaping (_ role: MDJUserRole) -> Void)

    /// Begin observing the deletion of a specific user.
    ///
    /// - note: This will fail unless the currently authenticated user is a user manager or an admin.
    ///
    /// - parameter userID: The identifier of the user to observe deletion.
    /// - parameter onDeletion: A block that is called when the user has been deleted.
    func beginObservingUserDeletion(forUserWithUserID userID: String, onDeletion: @escaping () -> Void)
}

// MARK: - MDJDefaultCurrentUserDatabaseObserver

class MDJDefaultCurrentUserDatabaseObserver {
    fileprivate let databaseReference: MDJDatabaseReference
    fileprivate var roleHandle: UInt?
    fileprivate var deletionHandle: UInt?

    init(databaseReference: MDJDatabaseReference) {
        self.databaseReference = databaseReference
    }

    deinit {
        tearDownRoleObserver()
        tearDownDeletionObserver()
    }
}

// MARK: MDJCurrentUserDatabaseObserver Methods

extension MDJDefaultCurrentUserDatabaseObserver: MDJCurrentUserDatabaseObserver {

    func beginObservingUserRole(forUserWithID userID: String, onRoleUpdated: @escaping (MDJUserRole) -> Void) {
        tearDownRoleObserver()

        let path = MDJDatabaseConstants.Path.users(forUserID: userID)
        roleHandle = databaseReference.child(path).observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [AnyHashable : Any],
                let roleRawValue = value[MDJDatabaseConstants.Key.role] as? Int,
                let role = MDJUserRole(rawValue: roleRawValue) else { return }

            onRoleUpdated(role)
        }
    }

    func beginObservingUserDeletion(forUserWithUserID userID: String, onDeletion: @escaping () -> Void) {
        tearDownDeletionObserver()

        let path = MDJDatabaseConstants.Path.users(forUserID: userID)
        deletionHandle = databaseReference.child(path).observe(.childRemoved) { (_) in
            onDeletion()
        }
    }
}

// MARK: Private Methods

private extension MDJDefaultCurrentUserDatabaseObserver {

    func tearDownRoleObserver() {
        if let handle = roleHandle {
            databaseReference.removeObserver(withHandle: handle)
        }
        roleHandle = nil
    }

    func tearDownDeletionObserver() {
        if let handle = deletionHandle {
            databaseReference.removeObserver(withHandle: handle)
        }
        deletionHandle = nil
    }
}

// MARK: - MDJCurrentUserDatabaseObserverAssembly

class MDJCurrentUserDatabaseObserverAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(MDJCurrentUserDatabaseObserver.self,
                               initializer: MDJDefaultCurrentUserDatabaseObserver.init).inObjectScope(.transient)
    }
}
