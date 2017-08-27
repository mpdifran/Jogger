//
//  LogInViewController.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-18.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit
import Swinject
import SwinjectStoryboard

// MARK: - LogInViewController

class LogInViewController: BaseAuthViewController {
    override var authenticatingAlertTitle: String {
        return "logging_in".localized()
    }

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
}

// MARK: View Lifecycle Methods

extension LogInViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        textFields = [emailTextField, passwordTextField]
    }
}

//MARK: Overridden Methods

extension LogInViewController {

    override func performAuthentication(completion: @escaping (Error?) -> Void) -> Bool {
        guard let email = emailTextField.text, !email.isEmpty else { handle(.missingEmail); return false }
        guard let password = passwordTextField.text, !password.isEmpty else { handle(.missingPassword); return false }

        authManager.signIn(withEmail: email, password: password) { (error) in
            completion(error)
        }
        return true
    }
}

// MARK: IBAction Methods

extension LogInViewController {

    @IBAction func didTapLogIn(_ sender: Any) {
        authenticate()
    }
}

// MARK: - LogInViewControllerAssembly

class LogInViewControllerAssembly: Assembly {

    func assemble(container: Container) {
        container.storyboardInitCompleted(LogInViewController.self) { (r, c) in
            c.authManager = r.resolve(MDJAuthenticationManager.self)!
        }
    }
}
