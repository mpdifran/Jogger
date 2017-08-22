//
//  MDJUserDatabaseObserver.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-20.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration

// MARK: - Notifications

extension Notification.Name {
    static let MDJUserDatabaseObserverUsersUpdated =
        Notification.Name("Notification.Name.MDJUserDatabaseObserverUsersUpdated")
}

// MARK: - MDJUserDatabaseObserver

protocol MDJUserDatabaseObserver: class {
    var users: [JogUser] { get }

    func beginObservingUsers()
}

// MARK: - MDJDefaultUserDatabaseObserver

class MDJDefaultUserDatabaseObserver {
    var users = [JogUser]() {
        didSet {
            NotificationCenter.default.post(name: .MDJUserDatabaseObserverUsersUpdated, object: self)
        }
    }

    fileprivate let databaseReference: MDJDatabaseReference
    fileprivate var handle: UInt?

    init(databaseReference: MDJDatabaseReference) {
        self.databaseReference = databaseReference
    }

    deinit {
        tearDownObserver()
    }
}

// MARK: MDJUserDatabaseObserver Methods

extension MDJDefaultUserDatabaseObserver: MDJUserDatabaseObserver {

    func beginObservingUsers() {
        tearDownObserver()

        users.removeAll(keepingCapacity: true)

        let path = MDJDatabaseConstants.Path.users
        handle = databaseReference.child(path).observe(.value, with: parse(_:))
    }
}

// MARK: Private Methods

private extension MDJDefaultUserDatabaseObserver {

    func tearDownObserver() {
        if let handle = handle {
            databaseReference.removeObserver(withHandle: handle)
        }
        handle = nil
    }

    func parse(_ snapshot: MDJDataSnapshot) {
        var users = [JogUser]()

        defer {
            self.users = users
        }

        guard let usersDictionary = snapshot.value as? [String : [AnyHashable : Any]] else { return }

        for userIdentifier in usersDictionary.keys {
            guard let userDictionary = usersDictionary[userIdentifier] else { continue }
            guard let user = createUser(from: userDictionary, withUserID: userIdentifier) else { continue }

            users.append(user)
        }
    }

    func createUser(from dictionary: [AnyHashable : Any], withUserID userID: String) -> JogUser? {
        guard let email = dictionary[MDJDatabaseConstants.Key.email] as? String,
            let roleRawValue = dictionary[MDJDatabaseConstants.Key.role] as? Int,
            let role = MDJUserRole(rawValue: roleRawValue) else { return nil }

        return JogUser(email: email, userID: userID, role: role)
    }
}

// MARK: - MDJDefaultUserDatabaseObserverAssembly

class MDJDefaultUserDatabaseObserverAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(MDJUserDatabaseObserver.self, initializer: MDJDefaultUserDatabaseObserver.init)
    }
}
