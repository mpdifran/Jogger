//
//  JogTableViewCell.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit

// MARK: - JogTableViewCell

class JogTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
}

// MARK: Cell Lifecycle Methods

extension JogTableViewCell {

    override func prepareForReuse() {
        super.prepareForReuse()

        dateLabel.text = nil
        timeLabel.text = nil
        distanceLabel.text = nil
        averageSpeedLabel.text = nil
    }
}
