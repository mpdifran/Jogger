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
    var jogs: [Jog] { get }
}

// MARK: - MDJJogsDatabaseObserverListModifier

protocol MDJJogsDatabaseObserverListModifier: class {

    /// Removes the specified jog from the list.
    func remove(jog: Jog)
}

// MARK: - MDJDefaultJogsDatabaseObserver

class MDJDefaultJogsDatabaseObserver {
    var jogs = [Jog]() {
        didSet {
            NotificationCenter.default.post(name: .MDJJogsDatabaseObserverJogsUpdated, object: self)
        }
    }

    fileprivate let userProvider: MDJUserProvider
    fileprivate let databaseReference: MDJDatabaseReference
    fileprivate var handle: UInt?

    fileprivate let dateFormatter = MDJDateFormatter()

    init(databaseReference: MDJDatabaseReference, userProvider: MDJUserProvider) {
        self.databaseReference = databaseReference
        self.userProvider = userProvider

        setupNotifications()
    }

    deinit {
        tearDownObserver()
    }
}

// MARK: MDJJogsDatabaseObserver Methods

extension MDJDefaultJogsDatabaseObserver: MDJJogsDatabaseObserver { }

// MARK: MDJJogsDatabaseObserverListModifier Methods

extension MDJDefaultJogsDatabaseObserver: MDJJogsDatabaseObserverListModifier {

    func remove(jog: Jog) {
        jogs = jogs.filter({ $0 !== jog })
    }
}

// MARK: Private Methods

private extension MDJDefaultJogsDatabaseObserver {

    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: .MDJUserProviderUserUpdated, object: userProvider,
                                               queue: .main) { [weak self] (_) in
                                                self?.setupObserver()
        }
    }

    func setupObserver() {
        tearDownObserver()

        if let user = userProvider.user {
            let path = MDJDatabaseConstants.Path.jogs(forUserID: user.uid)
            handle = databaseReference.child(path).observe(.value, with: parse(_:))
        }
    }

    func tearDownObserver() {
        if let handle = handle {
            databaseReference.removeObserver(withHandle: handle)
        }
        handle = nil
    }

    func parse(_ snapshot: MDJDataSnapshot) {
        var jogs = [Jog]()

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

    func createJog(from dictionary: [AnyHashable : Any]) -> Jog? {
        guard let dateString = dictionary[MDJDatabaseConstants.Key.date] as? String,
            let distance = dictionary[MDJDatabaseConstants.Key.distance] as? Double,
            let time = dictionary[MDJDatabaseConstants.Key.time] as? TimeInterval,
            let date = dateFormatter.date(from: dateString) else { return nil }

        return Jog(date: date, distance: distance, time: time)
    }
}

// MARK: - MDJJogsDatabaseObserverAssembly

class MDJJogsDatabaseObserverAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(MDJDefaultJogsDatabaseObserver.self, initializer: MDJDefaultJogsDatabaseObserver.init)
            .inObjectScope(.weak)
        container.register(MDJJogsDatabaseObserver.self, factory: { r in
            return r.resolve(MDJDefaultJogsDatabaseObserver.self)!
        }).inObjectScope(.weak)
        container.register(MDJJogsDatabaseObserverListModifier.self, factory: { r in
            return r.resolve(MDJDefaultJogsDatabaseObserver.self)!
        }).inObjectScope(.weak)
    }
}
