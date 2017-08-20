//
//  MDJUser.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-15.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Firebase

typealias AuthTokenCallback = FirebaseAuth.AuthTokenCallback
typealias MDJUserInfo = UserInfo

// MARK: - MDJUser

protocol MDJUser: class {
    var refreshToken: String? { get }
    var uid: String { get }
    var providerData: [MDJUserInfo] { get }

    func getIDToken(completion: AuthTokenCallback?)
}

// MARK: - User Extension

extension User: MDJUser { }
