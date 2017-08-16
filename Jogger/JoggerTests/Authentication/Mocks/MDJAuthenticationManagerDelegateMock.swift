//
//  MDJAuthenticationManagerDelegateMock.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-15.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
@testable import Jogger

// MARK: - MDJAuthenticationManagerDelegateMock

class MDJAuthenticationManagerDelegateMock: MDJAuthenticationManagerDelegate {
    var lastError: Error?

    func encountered(error: Error, in manager: MDJAuthenticationManager) {
        lastError = error
    }
}
