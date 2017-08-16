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
    static let MDJAuthenticationManagerUserUpdated =
        Notification.Name("Notification.Name.MDJAuthenticationManagerUserUpdated")
}

// MARK: - MDJUserProvider

protocol MDJUserProvider: class {
    var user: MDJUser? { get }
}

// MARK: - MDJAuthenticationManagerDelegate

protocol MDJAuthenticationManagerDelegate: class {

    func encountered(error: Error, in manager: MDJAuthenticationManager)
}

// MARK: - MDJAuthenticationManager

protocol MDJAuthenticationManager: class {
    var delegate: MDJAuthenticationManagerDelegate? { get set }

    func createUser(withEmail email: String, password: String)

    func signIn(withEmail email: String, password: String)

    func signOut()
}

// MARK: - MDJDefaultAuthenticationManager

class MDJDefaultAuthenticationManager {
    weak var delegate: MDJAuthenticationManagerDelegate?

    var user: MDJUser? {
        didSet {
            NotificationCenter.default.post(name: .MDJAuthenticationManagerUserUpdated, object: self)
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

    func createUser(withEmail email: String, password: String) {
        auth.createUser(withEmail: email, password: password, completion: handleAuthCallback(user:error:))
    }

    func signIn(withEmail email: String, password: String) {
        auth.signIn(withEmail: email, password: password, completion: handleAuthCallback(user:error:))
    }

    func signOut() {
        do {
            try auth.signOut()
        } catch {
            delegate?.encountered(error: error, in: self)
        }
    }
}

// MARK: - Private Methods

private extension MDJDefaultAuthenticationManager {

    func handleAuthCallback(user: MDJUser?, error: Error?) {
        self.user = user

        if let error = error {
            delegate?.encountered(error: error, in: self)
        }
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
