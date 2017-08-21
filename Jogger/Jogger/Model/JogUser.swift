//
//  JogUser.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-20.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import FirebaseAuth

// MARK: - JogUser

class JogUser {
    let email: String
    let userID: String
    let role: MDJUserRole

    init(email: String, userID: String, role: MDJUserRole) {
        self.email = email
        self.userID = userID
        self.role = role
    }
}
