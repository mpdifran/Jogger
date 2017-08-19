//
//  MDJFirebaseApp.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Firebase
import Swinject

// MARK: - MDJFirebaseApp

protocol MDJFirebaseApp: class {
    
    func configure()
}

// MARK: - MDJFirebaseAppProxy

class MDJFirebaseAppProxy { }

// MARK: MDJFirebaseApp Methods

extension MDJFirebaseAppProxy: MDJFirebaseApp {

    func configure() {
        FirebaseApp.configure()
    }
}

// MARK: - MDJFirebaseAppAssembly

class MDJFirebaseAppAssembly: Assembly {

    func assemble(container: Container) {
        container.register(MDJFirebaseApp.self) { _ in
            return MDJFirebaseAppProxy()
        }
    }
}
