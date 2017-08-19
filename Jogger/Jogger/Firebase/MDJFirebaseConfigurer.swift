//
//  MDJFirebaseConfigurer.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration

// MARK: - MDJFirebaseConfigurer

protocol MDJFirebaseConfigurer: class {

    func configure()
}

// MARK: - MDJDefaultFirebaseConfigurer

class MDJDefaultFirebaseConfigurer {
    fileprivate let app: MDJFirebaseApp

    fileprivate var hasConfigured = false

    init(app: MDJFirebaseApp) {
        self.app = app
    }
}

// MARK: MDJFirebaseConfigurer Methods

extension MDJDefaultFirebaseConfigurer: MDJFirebaseConfigurer {

    func configure() {
        guard !hasConfigured else { return }

        app.configure()
        hasConfigured = true
    }
}

// MARK: - MDJFirebaseConfigurerAssembly

class MDJFirebaseConfigurerAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(MDJFirebaseConfigurer.self, initializer: MDJDefaultFirebaseConfigurer.init)
            .inObjectScope(.container)
    }
}
