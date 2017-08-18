//
//  MDJDataSnapshot.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-16.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import FirebaseDatabase

// MARK: - MDJDataSnapshot

protocol MDJDataSnapshot: class {
    var value: Any? { get }
}

// MARK: DataSnapshot Extension

extension DataSnapshot: MDJDataSnapshot { }
