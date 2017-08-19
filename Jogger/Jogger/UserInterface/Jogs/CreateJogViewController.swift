//
//  CreateJogViewController.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

// MARK: - CreateJogViewController

class CreateJogViewController: UITableViewController {
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
}

// MARK: View Lifecycle Methods

extension CreateJogViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        datePickerDidChange(datePicker)
    }
}

// MARK: UITextFieldDelegate Methods

extension CreateJogViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string) ?? ""

        return (Double(string) != nil || string.isEmpty) && !newString.isEmpty
    }
}

// MARK: IBAction Methods

extension CreateJogViewController {

    @IBAction func datePickerDidChange(_ sender: UIDatePicker) {
        dateLabel.text = dateFormatter.string(from: sender.date)
    }

    @IBAction func didTapCancel(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func didTapCreate(_ sender: Any) {
        let jog = Jog(date: datePicker.date, distance: distance, time: time)

        if jogsDatabase.record(jog: jog) {
            presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Uh oh", message: "We were unable to save your jog.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - CreateJogViewControllerAssembly

class CreateJogViewControllerAssembly: Assembly {

    func assemble(container: Container) {
        container.storyboardInitCompleted(CreateJogViewController.self) { (r, c) in
            c.jogsDatabase = r.resolve(MDJJogsDatabase.self)!
        }
    }
}
