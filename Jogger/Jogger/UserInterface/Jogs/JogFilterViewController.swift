//
//  JogFilterViewController.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

// MARK: - JogFilterViewController

class JogFilterViewController: UITableViewController {
    var jogFilterObserver: MDJJogsFilterableDatabaseObserver!

    fileprivate let dateFormatter = DateFormatter()

    fileprivate var pickedFromDate: Date?
    fileprivate var pickedToDate: Date?

    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var fromDatePicker: UIDatePicker!
    @IBOutlet weak var toDatePicker: UIDatePicker!
}

// MARK: View Lifecycle Methods

extension JogFilterViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        if let startDate = jogFilterObserver.startDate {
            pickedFromDate = startDate
            fromDatePicker.date = startDate
            fromDatePickerDidChange(self)
        }
        if let endDate = jogFilterObserver.endDate {
            pickedToDate = endDate
            toDatePicker.date = endDate
            toDatePickerDidChange(self)
        }
    }
}

// MARK: IBAction Methods

extension JogFilterViewController {

    @IBAction func fromDatePickerDidChange(_ sender: Any) {
        pickedFromDate = fromDatePicker.date
        let dateString = dateFormatter.string(from: fromDatePicker.date)
        fromDateLabel.text = dateString
    }

    @IBAction func didTapFromResetButton(_ sender: Any) {
        pickedFromDate = nil
        fromDateLabel.text = "None"
        fromDatePicker.setDate(Date(), animated: true)
    }

    @IBAction func toDatePickerDidChange(_ sender: Any) {
        pickedToDate = toDatePicker.date
        let dateString = dateFormatter.string(from: toDatePicker.date)
        toDateLabel.text = dateString
    }

    @IBAction func didTapToResetButton(_ sender: Any) {
        pickedToDate = nil
        toDateLabel.text = "None"
        toDatePicker.setDate(Date(), animated: true)
    }

    @IBAction func didTapSet(_ sender: Any) {
        jogFilterObserver.applyFilter(startDate: pickedFromDate, endDate: pickedToDate)

        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
