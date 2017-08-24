//
//  MDJUserRole.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-23.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation

// MARK: - MDJUserRole

enum MDJUserRole: Int {
    case `default` = 0
    case userManager = 1
    case admin = 2

    var name: String {
        switch self {
        case .default:
            return "User"
        case .userManager:
            return "User Manager"
        case .admin:
            return "Admin"
        }
    }

    static let allRoles: [MDJUserRole] = [.default, .userManager, .admin]
}
