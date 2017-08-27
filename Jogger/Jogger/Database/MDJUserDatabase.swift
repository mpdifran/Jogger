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

    /// Register a user in the database. This is necessary in order for the user to be considered authenticated.
    ///
    /// - parameter user: The user to register.
    /// - parameter role: The user's role.
    /// - parameter completion: A completion block that is called once the user has been registered, or if an error is
    /// encountered.
    /// - parameter authenticatedUser: The authenticated user that has been successfully registered. Will be nil if
    /// registration fails.
    /// - parameter error: An optional error, if one was encountered.
    func register(user: MDJUser, with role: MDJUserRole,
                  completion: @escaping (_ authenticatedUser: MDJAuthenticatedUser?, _ error: Error?) -> Void)

    /// Fetch information related to the user, such as email and role.
    ///
    /// - parameter user: The user to fetch information for.
    /// - parameter completion: A completion block that is called when the user information has been fetched.
    /// - parameter authenticatedUser: The authenticated user whose information has been fetched.
    func fetchAuthenticatedUser(for user: MDJUser,
                                completion: @escaping (_ authenticatedUser: MDJAuthenticatedUser?) -> Void)

    /// Update a user's role.
    ///
    /// - note: This will fail unless the currently authenticated user is a user manager or an admin.
    ///
    /// - parameter userID: The user identifier of the user to change roles for.
    /// - parameter role: The role to update the user to.
    /// - parameter completion: A completion block that is called when the role has been updated, or an error is
    /// encountered.
    /// - parameter error: An optional error, if one was encountered.
    func updateUserRole(forUserWithID userID: String, role: MDJUserRole, completion: @escaping (_ error: Error?) -> Void)

    /// Delete a user.
    ///
    /// - note: This will fail unless the currently authenticated user is a user manager or an admin.
    ///
    /// - parameter userID: The identifier of the user to delete.
    /// - parameter completion: A completion block that is called when the deletion has finished, or an error was
    /// encountered.
    /// - parameter error: An optional error, if one was encountered.
    func deleteUser(withUserID userID: String, completion: @escaping (_ error: Error?) -> Void)
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

    func register(user: MDJUser, with role: MDJUserRole,
                  completion: @escaping (MDJAuthenticatedUser?, Error?) -> Void) {

        let path = MDJDatabaseConstants.Path.users(forUserID: user.uid)
        let email = userEmail(from: user)

        let userData: [String : Any] = [MDJDatabaseConstants.Key.email : email,
                                        MDJDatabaseConstants.Key.role : role.rawValue]

        databaseReference.child(path).setValue(userData) { (error, _) in
            if let error = error {
                completion(nil, error)
            } else {
                let user = MDJAuthenticatedUser(user: user, role: role, email: email)
                completion(user, nil)
            }
        }
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

    func updateUserRole(forUserWithID userID: String, role: MDJUserRole, completion: @escaping (Error?) -> Void) {
        let path = MDJDatabaseConstants.Path.users(forUserID: userID)

        databaseReference.child(path).child(MDJDatabaseConstants.Key.role).setValue(role.rawValue) { (error, _) in
            completion(error)
        }
    }

    func deleteUser(withUserID userID: String, completion: @escaping (Error?) -> Void) {
        let userPath = MDJDatabaseConstants.Path.users(forUserID: userID)
        let jogsPath = MDJDatabaseConstants.Path.jogs(forUserID: userID)

        let values = [userPath : NSNull(),
                      jogsPath : NSNull()]

        databaseReference.updateChildValues(values) { (error, _) in
            completion(error)
        }
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
        return "unknown".localized()
    }
}

// MARK: - MDJUserDatabaseAssembly

class MDJUserDatabaseAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(MDJUserDatabase.self, initializer: MDJDefaultUserDatabase.init).inObjectScope(.weak)
    }
}
