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

    /// Creates a new jog in the database, or updates the jog if it already exists.
    ///
    /// - parameter jog: The jog to create or update in the database.
    /// - parameter userID: The user ID of the user to create the jog for.
    /// - returns: `true` if the jog was recorded, `false` otherwise.
    func createOrUpdate(jog: MDJJog, forUserID userID: String)

    /// Deletes a jog from the database. 
    ///
    /// - parameter jog: The jog to delete in the database.
    /// - parameter userID: The user ID of the user to delete the jog from.
    /// - returns: `true` if the jog is no longer in the database, `false` otherwise.
    func delete(jog: MDJJog, forUserID userID: String)
}

// MARK: - MDJDefaultJogsDatabase

class MDJDefaultJogsDatabase {
    fileprivate let databaseReference: MDJDatabaseReference

    fileprivate let dateFormatter = MDJDateFormatter()

    init(databaseReference: MDJDatabaseReference) {
        self.databaseReference = databaseReference
    }
}

// MARK: MDJJogsDatabase Methods

extension MDJDefaultJogsDatabase: MDJJogsDatabase {

    func createOrUpdate(jog: MDJJog, forUserID userID: String) {
        let jogData = createDictionaryRepresentation(for: jog)

        let path = MDJDatabaseConstants.Path.jogs(forUserID: userID)

        if let identifier = jog.identifier {
            databaseReference.child(path).child(identifier).setValue(jogData)
        } else {
            databaseReference.child(path).childByAutoId().setValue(jogData)
        }
    }

    func delete(jog: MDJJog, forUserID userID: String) {
        guard let identifier = jog.identifier else { return }

        let path = MDJDatabaseConstants.Path.jogs(forUserID: userID)
        databaseReference.child(path).child(identifier).removeValue()
    }
}

// MARK: Private Methods

private extension MDJDefaultJogsDatabase {

    func createDictionaryRepresentation(for jog: MDJJog) -> [AnyHashable : Any] {
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
