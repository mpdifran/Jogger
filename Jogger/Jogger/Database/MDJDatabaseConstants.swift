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

        private init() { }
    }

    struct Path {

        static func jogs(for user: MDJUser) -> String {
            return "jogs/\(user.uid)"
        }

        private init() { }
    }

    private init() { }
}
