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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showLoginIfNoUserPresent()
    }
}

// MARK: Private Methods

private extension RootTabBarController {

    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .MDJUserProviderUserUpdated, object: userProvider,
                                               queue: .main) { [weak self] (_) in
                                                self?.handleUserUpdate()
        }
    }

    func handleUserUpdate() {
        guard let user = userProvider.user else { showLoginIfNoUserPresent(); return }

        let jogs = UIStoryboard(name: "Jogs", bundle: nil).instantiateInitialViewController()!
        let reports = UIStoryboard(name: "Reports", bundle: nil).instantiateInitialViewController()!
        let users = UIStoryboard(name: "Users", bundle: nil).instantiateInitialViewController()!

        switch user.role {
        case .default:
            setViewControllers([jogs, reports], animated: false)
        case .userManager, .admin:
            setViewControllers([jogs, reports, users], animated: false)
        }
    }

    func showLoginIfNoUserPresent() {
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
