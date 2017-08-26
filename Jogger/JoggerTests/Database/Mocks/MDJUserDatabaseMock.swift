//
//  MDJUserDatabaseMock.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-25.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
@testable import Jogger

// MARK: - MDJUserDatabaseMock

class MDJUserDatabaseMock: MDJUserDatabase {
    var lastUser: MDJUser?
    var lastRole: MDJUserRole?
    var lastUserID: String?

    var lastRegisterCompletion: ((MDJAuthenticatedUser?, Error?) -> Void)?
    var lastFetchAuthenticatedUserCompletion: ((MDJAuthenticatedUser?) -> Void)?
    var lastUpdateUserRoleCompletion: ((Error?) -> Void)?
    var lastDeleteCompletion: ((Error?) -> Void)?

    var didRegisterUser = false
    var didFetchAuthenticatedUser = false
    var didUpdateUserRole = false
    var didDeleteUser = false

    func register(user: MDJUser, with role: MDJUserRole, completion: @escaping (MDJAuthenticatedUser?, Error?) -> Void) {
        lastUser = user
        lastRole = role
        lastRegisterCompletion = completion
        didRegisterUser = true
    }

    func fetchAuthenticatedUser(for user: MDJUser, completion: @escaping (MDJAuthenticatedUser?) -> Void) {
        lastUser = user
        lastFetchAuthenticatedUserCompletion = completion
        didFetchAuthenticatedUser = true
    }

    func updateUserRole(forUserWithID userID: String, role: MDJUserRole, completion: @escaping (Error?) -> Void) {
        lastUserID = userID
        lastRole = role
        lastUpdateUserRoleCompletion = completion
        didUpdateUserRole = true
    }

    func deleteUser(withUserID userID: String, completion: @escaping (Error?) -> Void) {
        lastUserID = userID
        didDeleteUser = true
        lastDeleteCompletion = completion
    }
}
