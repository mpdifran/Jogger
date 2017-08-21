//
//  MainAssembler.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-15.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Swinject
import SwinjectStoryboard

// MARK: - MainAssembler

class MainAssembler {
    var resolver: Resolver {
        return assembler.resolver
    }
    private let assembler = Assembler(container: SwinjectStoryboard.defaultContainer)

    init() {
        Container.loggingFunction = nil

        assembler.apply(assembly: MDJAuthAssembly())
        assembler.apply(assembly: MDJAuthenticationManagerAssembly())
        assembler.apply(assembly: MDJDatabaseReferenceAssembly())
        assembler.apply(assembly: LogInViewControllerAssembly())
        assembler.apply(assembly: RootTabBarControllerAssembly())
        assembler.apply(assembly: CreateAccountViewControllerAssembly())
        assembler.apply(assembly: JogListViewControllerAssembly())
        assembler.apply(assembly: MDJFirebaseAppAssembly())
        assembler.apply(assembly: MDJFirebaseConfigurerAssembly())
        assembler.apply(assembly: CreateEditJogViewControllerAssembly())
        assembler.apply(assembly: MDJJogsDatabaseAssembly())
        assembler.apply(assembly: MDJJogsDatabaseObserverAssembly())
        assembler.apply(assembly: MDJJogsFilterableDatabaseObserverAssembly())
        assembler.apply(assembly: MDJUserDatabaseAssembly())
    }
}
