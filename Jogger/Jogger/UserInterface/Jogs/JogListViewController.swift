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

    fileprivate struct Segue {
        static let editJog = "JogEditSegue"
    }

    fileprivate var jogsObserver: MDJJogsFilterableDatabaseObserver!
    fileprivate var jogsDatabase: MDJJogsDatabase!

    fileprivate let dateFormatter = DateFormatter()
}

// MARK: View Lifecycle Methods

extension JogListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        setupNotifications()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }

        switch identifier {
        case Segue.editJog:
            guard let editViewController = segue.destination as? CreateEditJogViewController else { return }

            if let indexPath = tableView.indexPathForSelectedRow {
                let jog = jogsObserver.jogs[indexPath.row]
                editViewController.jog = jog
            }
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

            let _ = jogsDatabase.delete(jog: jog)
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
    }
}

// MARK: - JogListViewControllerAssembly

class JogListViewControllerAssembly: Assembly {

    func assemble(container: Container) {
        container.storyboardInitCompleted(JogListViewController.self) { (r, c) in
            c.jogsObserver = r.resolve(MDJJogsFilterableDatabaseObserver.self)!
            c.jogsDatabase = r.resolve(MDJJogsDatabase.self)!
        }
    }
}
