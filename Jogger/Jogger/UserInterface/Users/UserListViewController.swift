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
    fileprivate struct Segue {
        static let jogList = "JogListSegue"

        private init() { }
    }

    fileprivate var usersObserver: MDJUserDatabaseObserver!
    fileprivate var userDatabase: MDJUserDatabase!
    fileprivate var userProvider: MDJUserProvider!
}

// MARK: View Lifecycle Methods

extension UserListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotifications()

        usersObserver.beginObservingUsers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.allowsSelection = userProvider.user?.role == .admin
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }

        switch identifier {
        case Segue.jogList:
            guard let jogListViewController = segue.destination as? JogListViewController else { return }
            guard let indexPath = tableView.indexPathForSelectedRow else { return }

            let user = usersObserver.users[indexPath.row]
            jogListViewController.userID = user.userID
        default:
            break
        }
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
        cell.accessoryType = userProvider.user?.role == .admin ? .disclosureIndicator : .none

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let currentUser = userProvider.user else { return true }

        let user = usersObserver.users[indexPath.row]

        return currentUser.uid != user.userID
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {

    }

    override func tableView(_ tableView: UITableView,
                            editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let user = usersObserver.users[indexPath.row]

        let roleChange = UITableViewRowAction(style: .normal, title: "Update Role") { [weak self] (_, _) in

            let updateRole = { [weak self] (role: MDJUserRole) in
                self?.userDatabase.updateUserRole(forUserWithID: user.userID, role: role) { (error) in
                    self?.handle(error: error)
                }
            }

            let alertController = UIAlertController(title: "Update Role for \(user.email)", message: nil,
                                                    preferredStyle: .actionSheet)
            for role in MDJUserRole.allRoles {
                let action = UIAlertAction(title: role.name, style: .default) { (_) in
                    updateRole(role)
                }
                alertController.addAction(action)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)

            self?.present(alertController, animated: true, completion: nil)
        }

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (_, indexPath) in
            guard let user = self?.usersObserver.users[indexPath.row] else { return }

            self?.userDatabase.deleteUser(withUserID: user.userID)
        }

        return [delete, roleChange]
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
            c.userDatabase = r.resolve(MDJUserDatabase.self)!
            c.userProvider = r.resolve(MDJUserProvider.self)!
        }
    }
}
