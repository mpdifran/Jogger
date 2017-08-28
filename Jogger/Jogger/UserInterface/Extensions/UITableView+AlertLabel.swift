//
//  UITableView+AlertLabel.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-28.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit

// MARK: - UITableView+AlertLabel

extension UITableView {

    func showAlert(withMessage message: String?) {
        guard let message = message else {
            backgroundView = nil
            separatorStyle = .singleLine
            return
        }

        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        backgroundView = label
        separatorStyle = .none
    }
}
