//
//  MDJDateFormatter.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-16.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import Foundation

// MARK: - MDJDateFormatter

class MDJDateFormatter: DateFormatter {

    override init() {
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        timeZone = TimeZone(abbreviation: "UTC")
        locale = Locale(identifier: "en_US_POSIX")
    }
}
