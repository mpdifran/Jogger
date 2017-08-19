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

// MARK: - MDJUserProvider

protocol MDJUserProvider: class {
    var user: MDJUser? { get }
}

// MARK: - MDJAuthenticationManager

protocol MDJAuthenticationManager: class {
    func createUser(withEmail email: String, password: String, completion: @escaping (Error?) -> Void)

    func signIn(withEmail email: String, password: String, completion: @escaping (Error?) -> Void)

    func signOut() -> Error?
}

// MARK: - MDJDefaultAuthenticationManager

class MDJDefaultAuthenticationManager {
    var user: MDJUser? {
        didSet {
            NotificationCenter.default.post(name: .MDJUserProviderUserUpdated, object: self)
        }
    }

    fileprivate let auth: MDJAuth

    init(auth: MDJAuth) {
        self.auth = auth
    }
}

// MARK: MDJUserProvider Methods

extension MDJDefaultAuthenticationManager: MDJUserProvider { }

// MARK: MDJAuthenticationManager Methods

extension MDJDefaultAuthenticationManager: MDJAuthenticationManager {

    func createUser(withEmail email: String, password: String, completion: @escaping (Error?) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] (user, error) in
            self?.user = user

            completion(error)
        }
    }

    func signIn(withEmail email: String, password: String, completion: @escaping (Error?) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] (user, error) in
            self?.user = user

            completion(error)
        }
    }

    func signOut() -> Error? {
        do {
            try auth.signOut()
        } catch {
            return error
        }
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
