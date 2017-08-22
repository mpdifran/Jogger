//
//  UserListViewController.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-20.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

// MARK: - UserListViewController

class UserListViewController: UITableViewController {
    fileprivate var usersObserver: MDJUserDatabaseObserver!
}

// MARK: View Lifecycle Methods

extension UserListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotifications()

        usersObserver.beginObservingUsers()
    }
}

// MARK: UITableViewDataSource Methods

extension UserListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersObserver.users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: UserTableViewCell.self, for: indexPath)

        let user = usersObserver.users[indexPath.row]

        cell.emailLabel.text = user.email
        cell.userIdentifierLabel.text = user.userID
        cell.roleLabel.text = user.role.name

        return cell
    }
}

// MARK: Private Methods

private extension UserListViewController {

    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .MDJUserDatabaseObserverUsersUpdated, object: usersObserver,
                                               queue: .main) { [weak self] (_) in
                                                self?.tableView.reloadData()
        }
    }
}

// MARK: - UserListViewControllerAssembly

class UserListViewControllerAssembly: Assembly {

    func assemble(container: Container) {
        container.storyboardInitCompleted(UserListViewController.self) { (r, c) in
            c.usersObserver = r.resolve(MDJUserDatabaseObserver.self)!
        }
    }
}
