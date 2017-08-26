//
//  MDJJogsDatabaseObserver.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-16.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration

// MARK: - Notifications

extension Notification.Name {
    static let MDJJogsDatabaseObserverJogsUpdated =
        Notification.Name("Notification.Name.MDJJogsDatabaseObserverJogsUpdated")
}

// MARK: - MDJJogsDatabaseObserver

protocol MDJJogsDatabaseObserver: class {
    var jogs: [MDJJog] { get }

    func beginObservingJogs(forUserWithUserID userID: String)
}

// MARK: - MDJDefaultJogsDatabaseObserver

class MDJDefaultJogsDatabaseObserver {
    var jogs = [MDJJog]() {
        didSet {
            NotificationCenter.default.post(name: .MDJJogsDatabaseObserverJogsUpdated, object: self)
        }
    }

    fileprivate let databaseReference: MDJDatabaseReference
    fileprivate var handle: UInt?

    fileprivate let dateFormatter = MDJDateFormatter()

    init(databaseReference: MDJDatabaseReference) {
        self.databaseReference = databaseReference
    }

    deinit {
        tearDownObserver()
    }
}

// MARK: MDJJogsDatabaseObserver Methods

extension MDJDefaultJogsDatabaseObserver: MDJJogsDatabaseObserver {

    func beginObservingJogs(forUserWithUserID userID: String) {
        tearDownObserver()

        jogs.removeAll(keepingCapacity: true)

        let path = MDJDatabaseConstants.Path.jogs(forUserID: userID)
        handle = databaseReference.child(path).observe(.value) { [weak self] (snapshot) in
            self?.parse(snapshot)
        }
    }
}

// MARK: Private Methods

private extension MDJDefaultJogsDatabaseObserver {

    func tearDownObserver() {
        if let handle = handle {
            databaseReference.removeObserver(withHandle: handle)
        }
        handle = nil
    }

    func parse(_ snapshot: MDJDataSnapshot) {
        var jogs = [MDJJog]()

        defer {
            self.jogs = jogs
        }

        guard let jogsDictionary = snapshot.value as? [String : [AnyHashable : Any]] else { return }

        for jogIdentifier in jogsDictionary.keys {
            guard let jogDictionary = jogsDictionary[jogIdentifier] else { continue }
            guard let jog = createJog(from: jogDictionary) else { continue }

            jog.identifier = jogIdentifier
            jogs.append(jog)
        }
    }

    func createJog(from dictionary: [AnyHashable : Any]) -> MDJJog? {
        guard let dateString = dictionary[MDJDatabaseConstants.Key.date] as? String,
            let distance = dictionary[MDJDatabaseConstants.Key.distance] as? Double,
            let time = dictionary[MDJDatabaseConstants.Key.time] as? TimeInterval,
            let date = dateFormatter.date(from: dateString) else { return nil }

        return MDJJog(date: date, distance: distance, time: time)
    }
}

// MARK: - MDJJogsDatabaseObserverAssembly

class MDJJogsDatabaseObserverAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(MDJJogsDatabaseObserver.self, initializer: MDJDefaultJogsDatabaseObserver.init)
            .inObjectScope(.transient)
    }
}
