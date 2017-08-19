//
//  MDJAuth.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-15.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Firebase
import Swinject

// MARK: - Typealiases

typealias AuthResultCallback = (MDJUser?, Error?) -> Void

// MARK: - MDJAuth

protocol MDJAuth: class {

    func createUser(withEmail email: String, password: String, completion: @escaping AuthResultCallback)
    func signIn(withEmail email: String, password: String, completion: @escaping AuthResultCallback)
    func signOut() throws
}

// MARK: - Auth Extension

extension Auth: MDJAuth {

    func createUser(withEmail email: String, password: String, completion: @escaping AuthResultCallback) {
        createUser(withEmail: email, password: password) { (user: User?, error: Error?) in
            completion(user, error)
        }
    }

    func signIn(withEmail email: String, password: String, completion: @escaping AuthResultCallback) {
        signIn(withEmail: email, password: password) { (user: User?, error: Error?) in
            completion(user, error)
        }
    }
}

// MARK: - MDJAuthAssembly

class MDJAuthAssembly: Assembly {

    func assemble(container: Container) {
        container.register(MDJAuth.self) { r in
            let configurer = r.resolve(MDJFirebaseConfigurer.self)!
            configurer.configure()
            return Auth.auth()
        }
    }
}
