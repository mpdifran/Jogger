//
//  JogListViewController.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

// MARK: - JogListViewController

class JogListViewController: UITableViewController {
    var userID: String! {
        didSet {
            guard let userID = userID else { return }

            jogsObserver.beginObservingJogs(forUserWithUserID: userID)
        }
    }

    fileprivate struct Segue {
        static let createJog = "CreateJogSegue"
        static let editJog = "JogEditSegue"
        static let filter = "FilterSegue"

        private init() { }
    }

    fileprivate var jogsObserver: MDJJogsFilterableDatabaseObserver!
    fileprivate var jogsDatabase: MDJJogsDatabase!
    fileprivate var userProvider: MDJUserProvider!

    fileprivate let dateFormatter = DateFormatter()
}

// MARK: View Lifecycle Methods

extension JogListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftItemsSupplementBackButton = true

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        // If we don't have a userID set, default to the signed in user.
        if userID == nil {
            userID = userProvider.user?.uid
        }

        setupNotifications()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }

        switch identifier {
        case Segue.createJog:
            guard let navController = segue.destination as? UINavigationController,
                let createViewController = navController.topViewController as? CreateEditJogViewController else { return }

            createViewController.userID = userID
        case Segue.editJog:
            guard let editViewController = segue.destination as? CreateEditJogViewController else { return }

            editViewController.userID = userID
            if let indexPath = tableView.indexPathForSelectedRow {
                let jog = jogsObserver.jogs[indexPath.row]
                editViewController.jog = jog
            }
        case Segue.filter:
            guard let navController = segue.destination as? UINavigationController,
                let filterViewController = navController.topViewController as? JogFilterViewController else { return }

            filterViewController.jogFilterObserver = jogsObserver
        default:
            break
        }
    }
}

// MARK: UITableViewDataSource Methods

extension JogListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jogsObserver.jogs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: JogTableViewCell.self, for: indexPath)

        let jog = jogsObserver.jogs[indexPath.row]

        cell.dateLabel.text = dateFormatter.string(from: jog.date)
        cell.timeLabel.text = String(format: "%.0f hours, %.0f minutes", jog.hours, jog.minutes)
        cell.distanceLabel.text = String(format: "%.0f km", jog.distance)
        cell.averageSpeedLabel.text = String(format: "avg %.2f km/h", jog.averageSpeed)

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let jog = jogsObserver.jogs[indexPath.row]

            let _ = jogsDatabase.delete(jog: jog, forUserID: userID)
        default:
            break
        }
    }
}

// MARK: Private Methods

private extension JogListViewController {

    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .MDJJogsFilterableDatabaseObserverJogsUpdated, object: jogsObserver,
                                               queue: .main) { [weak self] (_) in
                                                self?.tableView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .MDJUserProviderUserUpdated, object: userProvider,
                                               queue: .main) { [weak self] (_) in

                                                // If we don't have a userID set, default to the signed in user.
                                                if self?.userID == nil {
                                                    self?.userID = self?.userProvider.user?.uid
                                                }
        }
    }
}

// MARK: - JogListViewControllerAssembly

class JogListViewControllerAssembly: Assembly {

    func assemble(container: Container) {
        container.storyboardInitCompleted(JogListViewController.self) { (r, c) in
            c.jogsObserver = r.resolve(MDJJogsFilterableDatabaseObserver.self)!
            c.jogsDatabase = r.resolve(MDJJogsDatabase.self)!
            c.userProvider = r.resolve(MDJUserProvider.self)!
        }
    }
}
