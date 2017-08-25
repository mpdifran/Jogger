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
    /// - parameter completion: A completion block that is called when the data has been updated.
    /// - parameter error: An optional error, if one was encountered.
    func createOrUpdate(jog: MDJJog, forUserID userID: String, completion: @escaping (_ error: Error?) -> Void)

    /// Deletes a jog from the database. 
    ///
    /// - parameter jog: The jog to delete in the database.
    /// - parameter userID: The user ID of the user to delete the jog from.
    /// - parameter completion: A completion block that is called when the data has been deleted.
    /// - parameter error: An optional error, if one was encountered.
    func delete(jog: MDJJog, forUserID userID: String, completion: @escaping (_ error: Error?) -> Void)
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

    func createOrUpdate(jog: MDJJog, forUserID userID: String, completion: @escaping (Error?) -> Void) {
        let jogData = createDictionaryRepresentation(for: jog)

        let path = MDJDatabaseConstants.Path.jogs(forUserID: userID)

        if let identifier = jog.identifier {
            databaseReference.child(path).child(identifier).setValue(jogData) { (error, _) in
                completion(error)
            }
        } else {
            databaseReference.child(path).childByAutoId().setValue(jogData) { (error, _) in
                completion(error)
            }
        }
    }

    func delete(jog: MDJJog, forUserID userID: String, completion: @escaping (Error?) -> Void) {
        guard let identifier = jog.identifier else { return }

        let path = MDJDatabaseConstants.Path.jogs(forUserID: userID)
        databaseReference.child(path).child(identifier).removeValue() { (error, _) in
            completion(error)
        }
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
