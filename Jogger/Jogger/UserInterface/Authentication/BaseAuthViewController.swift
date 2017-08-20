//
//  BaseAuthViewController.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-19.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit

// MARK: - BaseAuthViewController

class BaseAuthViewController: UITableViewController {
    var authManager: MDJAuthenticationManager!

    enum AuthValidationError {
        case missingEmail
        case missingPassword
        case missingVerifyPassword
        case passwordsDoNotMatch
    }

    open var authenticatingAlertTitle: String {
        return "Authenticating"
    }
    final var textFields = [UITextField]()
}

// MARK: Internal Methods

extension BaseAuthViewController {

    /// Perform the authentication of the user. This should not be called directly, but implemented by a subclass. To
    /// begin authentication, call the `authenticate()` method.
    ///
    /// - parameter completion: The completion that is called when the authentication is done.
    /// - parameter error: An optional error that was encountered by the authentication.
    /// - returns: `true` if the authentication was performed, `false` otherwise.
    open func performAuthentication(completion: @escaping (_ error: Error?) -> Void) -> Bool {
        return false
    }

    /// Begin authenticating the user. Takes care of updating the UI, and handling errors.
    final func authenticate() {
        let alertController = UIAlertController(title: authenticatingAlertTitle, message: nil, preferredStyle: .alert)

        let result = performAuthentication { [weak self] (error) in
            alertController.dismiss(animated: true) {
                if error == nil {
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                } else {
                    // Handle auth error
                }
            }
        }

        if result {
            tableView.endEditing(true)
            present(alertController, animated: true, completion: nil)
        }
    }

    final func handle(_ error: AuthValidationError) {
        let message: String
        switch error {
        case .missingEmail:
            message = "Please enter your email."
        case .missingPassword:
            message = "Please enter your password."
        case .missingVerifyPassword:
            message = "Please verify your password."
        case .passwordsDoNotMatch:
            message = "Your passwords do not match."
        }

        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: UITextFieldDelegate Methods

extension BaseAuthViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let index = textFields.index(where: { $0 == textField }) else { return true }

        let nextIndex = index + 1
        if nextIndex < textFields.count {
            textFields[nextIndex].becomeFirstResponder()
        } else {
            authenticate()
        }

        return true
    }
}