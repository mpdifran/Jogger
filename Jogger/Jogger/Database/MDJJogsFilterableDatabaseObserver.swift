//
//  MDJJogsFilterableDatabaseObserver.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration

// MARK: - Notifications

extension Notification.Name {
    static let MDJJogsFilterableDatabaseObserverJogsUpdated =
        Notification.Name("Notification.Name.MDJJogsFilterableDatabaseObserverJogsUpdated")
}

// MARK: - MDJJogsFilterableDatabaseObserver

protocol MDJJogsFilterableDatabaseObserver: MDJJogsDatabaseObserver {
    var startDate: Date? { get }
    var endDate: Date? { get }

    func applyFilter(startDate: Date?, endDate: Date?)
}

// MARK: - MDJDefaultJogsFilterableDatabaseObserver

class MDJDefaultJogsFilterableDatabaseObserver {
    var jogs = [Jog]() {
        didSet {
            NotificationCenter.default.post(name: .MDJJogsFilterableDatabaseObserverJogsUpdated, object: self)
        }
    }

    var startDate: Date?
    var endDate: Date?

    fileprivate let jogsObserver: MDJJogsDatabaseObserver

    init(jogsObserver: MDJJogsDatabaseObserver) {
        self.jogsObserver = jogsObserver

        setupNotifications()
    }
}

// MARK: MDJJogsFilterableDatabaseObserver Methods

extension MDJDefaultJogsFilterableDatabaseObserver: MDJJogsFilterableDatabaseObserver {

    func beginObservingJogs(forUserWithUserID userID: String) {
        jogsObserver.beginObservingJogs(forUserWithUserID: userID)
    }

    func applyFilter(startDate: Date?, endDate: Date?) {
        self.startDate = startDate
        self.endDate = endDate

        updateJogsList()
    }
}

// MARK: Private Methods

private extension MDJDefaultJogsFilterableDatabaseObserver {

    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .MDJJogsDatabaseObserverJogsUpdated, object: jogsObserver,
                                               queue: .main) { [weak self] (_) in
                                                self?.updateJogsList()
        }
    }

    func updateJogsList() {
        jogs = jogsObserver.jogs.filter({
            if let startDate = startDate, $0.date.compare(startDate) == .orderedAscending {
                return false
            }
            if let endDate = endDate, $0.date.compare(endDate) == .orderedDescending {
                return false
            }
            return true
        })
    }
}

// MARK: - MDJJogsFilterableDatabaseObserverAssembly

class MDJJogsFilterableDatabaseObserverAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(MDJJogsFilterableDatabaseObserver.self,
                               initializer: MDJDefaultJogsFilterableDatabaseObserver.init).inObjectScope(.transient)
    }
}
