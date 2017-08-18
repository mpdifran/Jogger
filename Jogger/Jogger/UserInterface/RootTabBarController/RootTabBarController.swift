//
//  RootTabBarController.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-18.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

// MARK: - SegueIdentifier

private struct SegueIdentifier {
    static let authentication = "AuthenticationSegueIdentifier"
}

// MARK: - RootTabBarController

class RootTabBarController: UITabBarController {
    fileprivate var userProvider: MDJUserProvider!
}

// MARK: View Lifecycle

extension RootTabBarController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if userProvider.user == nil {
            performSegue(withIdentifier: SegueIdentifier.authentication, sender: self)
        }
    }
}

// MARK: - RootTabBarControllerAssembly

class RootTabBarControllerAssembly: Assembly {

    func assemble(container: Container) {
        container.storyboardInitCompleted(RootTabBarController.self) { (r, c) in
            c.userProvider = r.resolve(MDJUserProvider.self)!
        }
    }
}
