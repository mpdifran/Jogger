//
//  UserTableViewCell.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-20.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit

// MARK: - UserTableViewCell

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var userIdentifierLabel: UILabel!
}

// MARK: Cell Lifecycle Methods

extension UserTableViewCell {

    override func prepareForReuse() {
        super.prepareForReuse()

        emailLabel.text = nil
        roleLabel.text = nil
        userIdentifierLabel.text = nil
    }
}
