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

// MARK: - MDJUserRole

enum MDJUserRole: Int {
    case `default` = 0
    case userManager = 1
    case admin = 2

    var name: String {
        switch self {
        case .default:
            return "User"
        case .userManager:
            return "User Manager"
        case .admin:
            return "Admin"
        }
    }
}

// MARK: - MDJUserDatabase

protocol MDJUserDatabase: class {

    func register(user: MDJUser, with role: MDJUserRole) -> MDJAuthenticatedUser

    func fetchAuthenticatedUser(for user: MDJUser, completion: @escaping (MDJAuthenticatedUser?) -> Void)

    func updateUserRole(forUserWithID userID: String, role: MDJUserRole) -> Bool
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

        return MDJAuthenticatedUser(user: user, role: role)
    }

    func fetchAuthenticatedUser(for user: MDJUser, completion: @escaping (MDJAuthenticatedUser?) -> Void) {
        let path = MDJDatabaseConstants.Path.users(forUserID: user.uid)

        databaseReference.child(path).child(MDJDatabaseConstants.Key.role).observeSingleEvent(of: .value) { (snapshot) in
            guard let roleRawValue = snapshot.value as? Int,
                let role = MDJUserRole(rawValue: roleRawValue) else { completion(nil); return }

            let authenticatedUser = MDJAuthenticatedUser(user: user, role: role)
            completion(authenticatedUser)
        }
    }

    func updateUserRole(forUserWithID userID: String, role: MDJUserRole) -> Bool {
        let path = MDJDatabaseConstants.Path.users(forUserID: userID)

        databaseReference.child(path).child(MDJDatabaseConstants.Key.role).setValue(role.rawValue)

        return true
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
