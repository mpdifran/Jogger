//
//  MDJAuthenticationManager.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-15.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration

// MARK: - Notifications

extension Notification.Name {
    static let MDJUserProviderUserUpdated = Notification.Name("Notification.Name.MDJUserProviderUserUpdated")
}

// MARK: - MDJAuthenticationError

enum MDJAuthenticationError: Error {
    case userDeleted
}

// MARK: - MDJUserProvider

protocol MDJUserProvider: class {
    var user: MDJAuthenticatedUser? { get }
}

// MARK: - MDJAuthenticationManager

protocol MDJAuthenticationManager: class {
    func createUser(withEmail email: String, password: String, role: MDJUserRole,
                    completion: @escaping (Error?) -> Void)

    func signIn(withEmail email: String, password: String, completion: @escaping (Error?) -> Void)

    func signOut() -> Error?
}

// MARK: - MDJDefaultAuthenticationManager

class MDJDefaultAuthenticationManager {
    var user: MDJAuthenticatedUser? {
        didSet {
            NotificationCenter.default.post(name: .MDJUserProviderUserUpdated, object: self)
        }
    }

    fileprivate let auth: MDJAuth
    fileprivate let userDatabase: MDJUserDatabase

    init(auth: MDJAuth, userDatabase: MDJUserDatabase) {
        self.auth = auth
        self.userDatabase = userDatabase
    }
}

// MARK: MDJUserProvider Methods

extension MDJDefaultAuthenticationManager: MDJUserProvider { }

// MARK: MDJAuthenticationManager Methods

extension MDJDefaultAuthenticationManager: MDJAuthenticationManager {

    func createUser(withEmail email: String, password: String, role: MDJUserRole,
                    completion: @escaping (Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] (user, error) in
            guard let user = user else {
                self?.user = nil
                completion(error)
                return
            }
            guard let authenticatedUser = self?.userDatabase.register(user: user, with: role) else {
                self?.user = nil
                completion(error)
                return
            }

            self?.user = authenticatedUser

            completion(error)
        }
    }

    func signIn(withEmail email: String, password: String, completion: @escaping (Error?) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] (user, error) in
            guard let user = user else {
                self?.user = nil
                completion(error)
                return
            }

            self?.userDatabase.fetchAuthenticatedUser(for: user) { (authenticatedUser) in
                self?.user = authenticatedUser

                if authenticatedUser == nil {
                    completion(MDJAuthenticationError.userDeleted)
                } else {
                    completion(error)
                }
            }
        }
    }

    func signOut() -> Error? {
        do {
            try auth.signOut()
        } catch {
            return error
        }
        user = nil
        return nil
    }
}

// MARK: - MDJAuthenticationManagerAssembly

class MDJAuthenticationManagerAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(MDJDefaultAuthenticationManager.self,
                               initializer: MDJDefaultAuthenticationManager.init).inObjectScope(.container)

        container.register(MDJUserProvider.self, factory: { r in
            return r.resolve(MDJDefaultAuthenticationManager.self)!
        }).inObjectScope(.container)
        container.register(MDJAuthenticationManager.self, factory: { r in
            return r.resolve(MDJDefaultAuthenticationManager.self)!
        }).inObjectScope(.container)
    }
}
