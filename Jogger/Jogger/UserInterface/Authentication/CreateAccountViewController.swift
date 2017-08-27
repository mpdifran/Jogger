//
//  CreateAccountViewController.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-18.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

// MARK: - CreateAccountViewController

class CreateAccountViewController: BaseAuthViewController {
    override var authenticatingAlertTitle: String {
        return "creating_account".localized()
    }

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var verifyPasswordTextField: UITextField!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
}

// MARK: View Lifecycle Methods

extension CreateAccountViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        textFields = [emailTextField, passwordTextField, verifyPasswordTextField]
    }
}

// MARK: Overridden Methods

extension CreateAccountViewController {

    override func performAuthentication(completion: @escaping (Error?) -> Void) -> Bool {
        guard let email = emailTextField.text, !email.isEmpty else { handle(.missingEmail); return false }
        guard let password = passwordTextField.text, !password.isEmpty else { handle(.missingPassword); return false }
        guard let verifiedPassword = verifyPasswordTextField.text, !password.isEmpty else { handle(.missingPassword); return false }

        guard verifiedPassword == password else { handle(.passwordsDoNotMatch); return false }

        guard let role = MDJUserRole(rawValue: roleSegmentedControl.selectedSegmentIndex) else { return false }

        authManager.createUser(withEmail: email, password: password, role: role) { (error) in
            completion(error)
        }
        return true
    }
}

// MARK: IBAction Methods

extension CreateAccountViewController {

    @IBAction func didTapCreateAccount(_ sender: Any) {
        authenticate()
    }
}

// MRK: - CreateAccountViewControllerAssembly

class CreateAccountViewControllerAssembly: Assembly {

    func assemble(container: Container) {
        container.storyboardInitCompleted(CreateAccountViewController.self) { (r, c) in
            c.authManager = r.resolve(MDJAuthenticationManager.self)!
        }
    }
}
