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

// MARK: - MDJAuthenticationErrorCode

enum MDJAuthenticationErrorCode: Int {
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

            if let user = user {
                userDeletionObserver.beginObservingUserDeletion(forUserWithUserID: user.uid, onDeletion: { [weak self] in
                    self?.user = nil
                })
            }
        }
    }

    fileprivate let auth: MDJAuth
    fileprivate let userDatabase: MDJUserDatabase
    fileprivate let userDeletionObserver: MDJUserDeletionDatabaseObserver

    init(auth: MDJAuth, userDatabase: MDJUserDatabase, userDeletionObserver: MDJUserDeletionDatabaseObserver) {
        self.auth = auth
        self.userDatabase = userDatabase
        self.userDeletionObserver = userDeletionObserver
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

            self?.userDatabase.register(user: user, with: role) { (authenticatedUser, error) in
                self?.user = authenticatedUser
                completion(error)
            }
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
                    let error = NSError(code: .userDeleted, description: "Your account has been deleted.")
                    completion(error)
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

// MARK: Private NSError Extension

private extension NSError {

    convenience init(code: MDJAuthenticationErrorCode, description: String) {
        let userInfo = [NSLocalizedDescriptionKey : description]
        let domain = "com.markdifranco.authenticationError"

        self.init(domain: domain, code: code.rawValue, userInfo: userInfo)
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
