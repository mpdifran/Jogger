//
//  ProfileViewController.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-23.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

// MARK: - ProfileViewController

class ProfileViewController: UITableViewController {
    fileprivate var authManager: MDJAuthenticationManager!
    fileprivate var userProvider: MDJUserProvider!

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
}

// MARK: View Lifecycle Methods

extension ProfileViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        updateUser()
    }
}

// MARK: Private Methods

private extension ProfileViewController {

    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .MDJUserProviderUserUpdated, object: userProvider,
                                               queue: .main) { [weak self] (_) in
                                                self?.updateUser()
        }
    }

    func updateUser() {
        emailLabel.text = userProvider.user?.email ?? "Unknown"
        roleLabel.text = userProvider.user?.role.name ?? "None"
    }
}

// MARK: IBAction Methods

extension ProfileViewController {

    @IBAction func didTapLogout(_ sender: Any) {
        if let error = authManager.signOut() {
            self.handle(error: error)
        }
    }
}

// MARK: - ProfileViewControllerAssembly

class ProfileViewControllerAssembly: Assembly {

    func assemble(container: Container) {
        container.storyboardInitCompleted(ProfileViewController.self) { (r, c) in
            c.authManager = r.resolve(MDJAuthenticationManager.self)!
            c.userProvider = r.resolve(MDJUserProvider.self)!
        }
    }
}
