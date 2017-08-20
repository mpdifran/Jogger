//
//  MDJJogsDatabase.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-16.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation
import Swinject
import SwinjectAutoregistration

// MARK: - MDJJogsDatabase

protocol MDJJogsDatabase: class {

    /// Record a jog for the currently authenticated user.
    ///
    /// - returns: `true` if the jog was recorded, `false` otherwise.
    func record(jog: Jog) -> Bool

    /// Deletes a jog from the database. 
    ///
    /// - returns: `true` if the jog is no longer in the database, `false` otherwise.
    func delete(jog: Jog) -> Bool
}

// MARK: - MDJDefaultJogsDatabase

class MDJDefaultJogsDatabase {
    fileprivate let databaseReference: MDJDatabaseReference
    fileprivate let jogsListModifier: MDJJogsDatabaseObserverListModifier
    fileprivate let userProvider: MDJUserProvider

    fileprivate let dateFormatter = MDJDateFormatter()

    init(databaseReference: MDJDatabaseReference, jogsListModifier: MDJJogsDatabaseObserverListModifier,
         userProvider: MDJUserProvider) {
        self.databaseReference = databaseReference
        self.jogsListModifier = jogsListModifier
        self.userProvider = userProvider
    }
}

// MARK: MDJJogsDatabase Methods

extension MDJDefaultJogsDatabase: MDJJogsDatabase {

    func record(jog: Jog) -> Bool {
        guard let user = userProvider.user else { return false }

        let jogData = createDictionaryRepresentation(for: jog)

        let path = MDJDatabaseConstants.Path.jogs(for: user)
        databaseReference.child(path).childByAutoId().setValue(jogData)

        return true
    }

    func delete(jog: Jog) -> Bool {
        guard let user = userProvider.user else { return false }
        guard let identifier = jog.identifier else { return true }

        jogsListModifier.remove(jog: jog)

        let path = MDJDatabaseConstants.Path.jogs(for: user)
        databaseReference.child(path).child(identifier).removeValue()

        return true
    }
}

// MARK: Private Methods

private extension MDJDefaultJogsDatabase {

    func createDictionaryRepresentation(for jog: Jog) -> [AnyHashable : Any] {
        return [MDJDatabaseConstants.Key.date : dateFormatter.string(from: jog.date),
                MDJDatabaseConstants.Key.distance : jog.distance,
                MDJDatabaseConstants.Key.time : jog.time]
    }
}

// MARK: - MDJJogsDatabaseAssembly

class MDJJogsDatabaseAssembly: Assembly {

    func assemble(container: Container) {
        container.autoregister(MDJJogsDatabase.self, initializer: MDJDefaultJogsDatabase.init).inObjectScope(.weak)
    }
}
