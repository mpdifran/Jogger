//
//  MDJUser.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-15.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Firebase

// MARK: - MDJUser

protocol MDJUser: class {
    var refreshToken: String? { get }

    func getIDToken(completion: FirebaseAuth.AuthTokenCallback?)
}

// MARK: - User Extension

extension User: MDJUser { }
