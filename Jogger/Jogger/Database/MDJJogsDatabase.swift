//
//  MDJJogsDatabase.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-16.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation

// MARK: - MDJJogsDatabase

protocol MDJJogsDatabase: class {

    func record(jog: Jog) -> Bool
}

// MARK: - MDJDefaultJogsDatabase

class MDJDefaultJogsDatabase {
    fileprivate let databaseReference: MDJDatabaseReference
    fileprivate let userProvider: MDJUserProvider

    fileprivate let dateFormatter = MDJDateFormatter()

    init(databaseReference: MDJDatabaseReference, userProvider: MDJUserProvider) {
        self.databaseReference = databaseReference
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
}

// MARK: Private Methods

private extension MDJDefaultJogsDatabase {

    func createDictionaryRepresentation(for jog: Jog) -> [AnyHashable : Any] {
        return [MDJDatabaseConstants.Key.date : dateFormatter.string(from: jog.date),
                MDJDatabaseConstants.Key.distance : jog.distance,
                MDJDatabaseConstants.Key.time : jog.time]
    }
}
