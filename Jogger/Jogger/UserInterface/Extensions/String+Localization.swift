//
//  String+Localization.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-26.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation

// MARK: - String+Localization

extension String {

    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
}
