//
//  NotificationObserver.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-26.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation

// MARK: - NotificationObserver

class NotificationObserver {
    var lastNotification: Notification?

    func observeNotification(name: Notification.Name, object: Any?) {
        NotificationCenter.default.addObserver(forName: name, object: object,
                                               queue: .main) { [weak self] (notification) in
                                                self?.lastNotification = notification
        }
    }
}
