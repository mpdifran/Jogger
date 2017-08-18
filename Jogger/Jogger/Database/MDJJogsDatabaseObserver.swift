//
//  MDJJogsDatabaseObserver.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-16.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation

// MARK: - Notifications

extension Notification.Name {
    static let MDJJogsDatabaseObserverJogsUpdated =
        Notification.Name("Notification.Name.MDJJogsDatabaseObserverJogsUpdated")
}

// MARK: - MDJJogsDatabaseObserver

protocol MDJJogsDatabaseObserver: class {
    var jogs: [Jog] { get }
}

// MARK: - MDJDefaultJogsDatabaseObserver

class MDJDefaultJogsDatabaseObserver {
    var jogs = [Jog]() {
        didSet {
            NotificationCenter.default.post(name: .MDJJogsDatabaseObserverJogsUpdated, object: self)
        }
    }

    fileprivate let databaseReference: MDJDatabaseReference
    fileprivate var handle: UInt?

    fileprivate let dateFormatter = MDJDateFormatter()

    init(databaseReference: MDJDatabaseReference, userProvider: MDJUserProvider) {
        self.databaseReference = databaseReference

        if let user = userProvider.user {
            let path = MDJDatabaseConstants.Path.jogs(for: user)
            handle = databaseReference.child(path).observe(.value, with: parse(_:))
        }
    }

    deinit {
        if let handle = handle {
            databaseReference.removeObserver(withHandle: handle)
        }
    }
}

// MARK: MDJJogsDatabaseObserver Methods

extension MDJDefaultJogsDatabaseObserver: MDJJogsDatabaseObserver { }

// MARK: Private Methods

private extension MDJDefaultJogsDatabaseObserver {

    func parse(_ snapshot: MDJDataSnapshot) {
        var jogs = [Jog]()

        defer {
            self.jogs = jogs
        }

        guard let jogsDictionary = snapshot.value as? [AnyHashable : [AnyHashable : Any]] else { return }

        for jogDictionary in jogsDictionary.values {
            guard let jog = createJog(from: jogDictionary) else { continue }

            jogs.append(jog)
        }
    }

    func createJog(from dictionary: [AnyHashable : Any]) -> Jog? {
        guard let dateString = dictionary[MDJDatabaseConstants.Key.date] as? String,
            let distance = dictionary[MDJDatabaseConstants.Key.distance] as? Double,
            let time = dictionary[MDJDatabaseConstants.Key.time] as? TimeInterval,
            let date = dateFormatter.date(from: dateString) else { return nil }

        return Jog(date: date, distance: distance, time: time)
    }
}