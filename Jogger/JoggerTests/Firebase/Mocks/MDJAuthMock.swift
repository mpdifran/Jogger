//
//  MDJAuthMock.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-15.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
@testable import Jogger

// MARK: - MDJAuthMock

class MDJAuthMock: MDJAuth {
    var didCreateUser = false
    var didSignIn = false
    var didSignOut = false

    var lastEmail: String?
    var lastPassword: String?
    var lastCompletion: AuthResultCallback?

    var errorToThrow: Error?

    func createUser(withEmail email: String, password: String, completion: @escaping AuthResultCallback) {
        didCreateUser = true

        lastEmail = email
        lastPassword = password
        lastCompletion = completion
    }

    func signIn(withEmail email: String, password: String, completion: @escaping AuthResultCallback) {
        didSignIn = true

        lastEmail = email
        lastPassword = password
        lastCompletion = completion
    }

    func signOut() throws {
        didSignOut = true

        if let error = errorToThrow {
            throw error
        }
    }
}
