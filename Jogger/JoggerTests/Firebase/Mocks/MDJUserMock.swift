//
//  MDJUserMock.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-18.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
@testable import Jogger

// MARK: - MDJUserMock

class MDJUserMock: MDJUser {
    var refreshToken: String?
    var uid = "user.identifier"
    var providerData = [MDJUserInfo]()

    var lastCompletion: AuthTokenCallback?

    func getIDToken(completion: AuthTokenCallback?) {
        lastCompletion = completion
    }
}
