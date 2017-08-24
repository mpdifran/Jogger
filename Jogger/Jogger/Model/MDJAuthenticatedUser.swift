//
//  MDJAuthenticatedUser.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-20.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation

// MARK: - MDJAuthenticatedUser

class MDJAuthenticatedUser {
    var uid: String {
        return user.uid
    }

    let user: MDJUser
    let role: MDJUserRole
    let email: String

    init(user: MDJUser, role: MDJUserRole, email: String) {
        self.user = user
        self.role = role
        self.email = email
    }
}
