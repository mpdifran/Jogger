//
//  MDJUserDatabase.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-20.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration

// MARK: - MDJUserDatabase

protocol MDJUserDatabase: class {

    func register(user: MDJUser, with role: MDJUserRole) -> MDJAuthenticatedUser

    func fetchAuthenticatedUser(for user: MDJUser, completion: @escaping (MDJAuthenticatedUser?) -> Void)

    func updateUserRole(forUserWithID userID: String, role: MDJUserRole)

    func deleteUser(withUserID userID: String)
}

// MARK: - MDJDefaultUserDatabase

class MDJDefaultUserDatabase {
    fileprivate let databaseReference: MDJDatabaseReference

    init(databaseReference: MDJDatabaseReference) {
        self.databaseReference = databaseReference
    }
}

// MARK: MDJUserDatabase Methods

extension MDJDefaultUserDatabase: MDJUserDatabase {

    func register(user: MDJUser, with role: MDJUserRole) -> MDJAuthenticatedUser {
        let path = MDJDatabaseConstants.Path.users(forUserID: user.uid)

        let email = userEmail(from: user)

        let userData: [String : Any] = [MDJDatabaseConstants.Key.email : email,
                                        MDJDatabaseConstants.Key.role : role.rawValue]

        databaseReference.child(path).setValue(userData)

        return MDJAuthenticatedUser(user: user, role: role, email: email)
    }

    func fetchAuthenticatedUser(for user: MDJUser, completion: @escaping (MDJAuthenticatedUser?) -> Void) {
        let path = MDJDatabaseConstants.Path.users(forUserID: user.uid)
        let email = userEmail(from: user)

        databaseReference.child(path).child(MDJDatabaseConstants.Key.role).observeSingleEvent(of: .value) { (snapshot) in
            guard let roleRawValue = snapshot.value as? Int,
                let role = MDJUserRole(rawValue: roleRawValue) else { completion(nil); return }

            let authenticatedUser = MDJAuthenticatedUser(user: user, role: role, email: email)
            completion(authenticatedUser)
        }
    }

    func updateUserRole(forUserWithID userID: String, role: MDJUserRole) {
        let path = MDJDatabaseConstants.Path.users(forUserID: userID)

        databaseReference.child(path).child(MDJDatabaseConstants.Key.role).setValue(role.rawValue)
    }

    func deleteUser(withUserID userID: String) {
        let userPath = MDJDatabaseConstants.Path.users(forUserID: userID)
        let jogsPath = MDJDatabaseConstants.Path.jogs(forUserID: userID)

        let values = [userPath : NSNull(),
                      jogsPath : NSNull()]

        databaseReference.updateChildValues(values)
    }
}

// MARK: Private Methods

private extension MDJDefaultUserDatabase {

    func userEmail(from user: MDJUser) -> String {
        if let userInfo = user.providerData.first {
            if let email = userInfo.email {
                return email
            }
        }
        return "Unknown"
    }
}

// MARK: - MDJUserDatabaseAssembly

class MDJUserDatabaseAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(MDJUserDatabase.self, initializer: MDJDefaultUserDatabase.init).inObjectScope(.weak)
    }
}
