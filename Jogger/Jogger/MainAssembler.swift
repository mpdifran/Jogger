//
//  MainAssembler.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-15.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Swinject

// MARK: - MainAssembler

class MainAssembler {
    var resolver: Resolver {
        return assembler.resolver
    }
    private let assembler = Assembler()

    init() {
        assembler.apply(assembly: MDJAuthAssembly())
        assembler.apply(assembly: MDJAuthenticationManagerAssembly())
    }
}
