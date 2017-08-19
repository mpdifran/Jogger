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
    fileprivate var jogsObserver: MDJJogsDatabaseObserver!

    fileprivate let dateFormatter = DateFormatter()
}

// MARK: View Lifecycle Methods

extension JogListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium

        setupNotifications()
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
        cell.timeLabel.text = "\(jog.time)"
        cell.distanceLabel.text = "\(jog.distance) km"

        return cell
    }
}

// MARK: Private Methods

private extension JogListViewController {

    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .MDJJogsDatabaseObserverJogsUpdated, object: jogsObserver,
                                               queue: .main) { [weak self] (_) in
                                                self?.tableView.reloadData()
        }
    }
}

// MARK: - JogListViewControllerAssembly

class JogListViewControllerAssembly: Assembly {

    func assemble(container: Container) {
        container.storyboardInitCompleted(JogListViewController.self) { (r, c) in
            c.jogsObserver = r.resolve(MDJJogsDatabaseObserver.self)!
        }
    }
}
