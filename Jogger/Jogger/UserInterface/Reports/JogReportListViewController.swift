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

        cell.dateLabel.text = String(format: "week_of_format".localized(), dateFormatter.string(from: jogReport.date))
        cell.averageSpeedLabel.text = String(format: "jog_average_speed_format".localized(), jogReport.averageSpeed)
        cell.totalDistanceLabel.text = String(format: "jog_total_distance_format".localized(), jogReport.totalDistance)

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
                                                self?.updateAlertLabel()
        }
    }

    func setupJogReportObserver() {
        guard let user = userProvider.user else { return }

        jogsReportsObserver.beginObservingJogReports(forUserWithUserID: user.uid)
    }

    func updateAlertLabel() {
        let message = jogsReportsObserver.jogReports.count > 0 ? nil : "no_jog_reports".localized()

        tableView.showAlert(withMessage: message)
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
