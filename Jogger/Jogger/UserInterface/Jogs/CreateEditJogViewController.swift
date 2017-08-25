//
//  CreateEditJogViewController.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

// MARK: - CreateEditJogViewController

class CreateEditJogViewController: UITableViewController {
    var userID: String!
    var jog = MDJJog() {
        didSet {
            createButton.title = "Update"
            navigationItem.leftBarButtonItem = nil

            title = "Edit Jog"
        }
    }

    fileprivate var jogsDatabase: MDJJogsDatabase!
    fileprivate let dateFormatter = DateFormatter()

    fileprivate var time: TimeInterval {
        guard let hours = Double(hoursTextField.text!), let minutes = Double(minutesTextField.text!) else { return 0 }

        return hours * 3600 + minutes * 60
    }
    fileprivate var distance: Double {
        return Double(distanceTextField.text!) ?? 0
    }

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var hoursTextField: UITextField!
    @IBOutlet weak var minutesTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var createButton: UIBarButtonItem!
}

// MARK: View Lifecycle Methods

extension CreateEditJogViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        datePicker.setDate(jog.date, animated: false)
        hoursTextField.text = String(format: "%.0f", jog.hours)
        minutesTextField.text = String(format: "%.0f", jog.minutes)
        distanceTextField.text = String(format: "%.0f", jog.distance)

        datePickerDidChange(datePicker)
    }
}

// MARK: UITextFieldDelegate Methods

extension CreateEditJogViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return (Double(string) != nil || string.isEmpty)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            textField.text = "0"
        }
    }
}

// MARK: IBAction Methods

extension CreateEditJogViewController {

    @IBAction func datePickerDidChange(_ sender: UIDatePicker) {
        dateLabel.text = dateFormatter.string(from: sender.date)
    }

    @IBAction func didTapCancel(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapCreate(_ sender: Any) {
        jog.date = datePicker.date
        jog.distance = distance
        jog.time = time

        jogsDatabase.createOrUpdate(jog: jog, forUserID: userID) { [weak self] (error) in
            self?.handle(error: error)

            guard error == nil else { return }

            if let presentingViewController = self?.presentingViewController {
                presentingViewController.dismiss(animated: true, completion: nil)
            } else {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

// MARK: - CreateEditJogViewControllerAssembly

class CreateEditJogViewControllerAssembly: Assembly {

    func assemble(container: Container) {
        container.storyboardInitCompleted(CreateEditJogViewController.self) { (r, c) in
            c.jogsDatabase = r.resolve(MDJJogsDatabase.self)!
        }
    }
}
