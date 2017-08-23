//
//  JogReportListViewController.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-22.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

// MARK: - JogReportListViewController

class JogReportListViewController: UITableViewController {
    fileprivate let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        return dateFormatter
    }()

    fileprivate var jogsReportsObserver: MDJJogReportDatabaseObserver!
    fileprivate var userProvider: MDJUserProvider!
}

// MARK: View Lifecycle Methods

extension JogReportListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotifications()
        setupJogReportObserver()
    }
}

// MARK: UITableViewDataSource Methods

extension JogReportListViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jogsReportsObserver.jogReports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: JogReportTableViewCell.self, for: indexPath)
        let jogReport = jogsReportsObserver.jogReports[indexPath.row]

        cell.dateLabel.text = "Week of \(dateFormatter.string(from: jogReport.date))"
        cell.averageSpeedLabel.text = String(format: "Average Speed: %.2f km/h", jogReport.averageSpeed)
        cell.totalDistanceLabel.text = String(format: "Total Distance: %.0f km", jogReport.totalDistance)

        return cell
    }
}

// MARK: Private Methods

private extension JogReportListViewController {

    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .MDJUserProviderUserUpdated, object: userProvider,
                                               queue: .main) { [weak self] (_) in
                                                self?.setupJogReportObserver()
        }
        NotificationCenter.default.addObserver(forName: .MDJJogReportDatabaseObserverJogReportsUpdated,
                                               object: jogsReportsObserver, queue: .main) { [weak self] (_) in
                                                self?.tableView.reloadData()
        }
    }

    func setupJogReportObserver() {
        guard let user = userProvider.user else { return }

        jogsReportsObserver.beginObservingJogReports(forUserWithUserID: user.uid)
    }
}

// MARK: - JogReportListViewControllerAssembly

class JogReportListViewControllerAssembly: Assembly {

    func assemble(container: Container) {
        container.storyboardInitCompleted(JogReportListViewController.self) { (r, c) in
            c.jogsReportsObserver = r.resolve(MDJJogReportDatabaseObserver.self)!
            c.userProvider = r.resolve(MDJUserProvider.self)!
        }
    }
}
