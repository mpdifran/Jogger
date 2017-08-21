//
//  MDJDatabaseConstants.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-16.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation

// MARK: - MDJDatabaseConstants

struct MDJDatabaseConstants {

    struct Key {
        static let date = "date"
        static let time = "time"
        static let distance = "distance"
        static let email = "email"
        static let role = "role"

        private init() { }
    }

    struct Path {

        static func jogs(forUserID userID: String) -> String {
            return "jogs/\(userID)"
        }
        static func users(forUserID userID: String) -> String {
            return "\(users)/\(userID)"
        }
        static let users = "users"

        private init() { }
    }

    private init() { }
}
