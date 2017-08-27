//
//  JogReportTableViewCell.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-22.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit

// MARK: - JogReportTableViewCell

class JogReportTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
}

// MARK: Cell Lifecycle Methods

extension JogReportTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        prepareForReuse()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        averageSpeedLabel.text = nil
        totalDistanceLabel.text = nil
    }
}
