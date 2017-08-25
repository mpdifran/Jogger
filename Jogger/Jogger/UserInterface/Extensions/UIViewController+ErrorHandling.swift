//
//  UIViewController+ErrorHandling.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-24.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit

// MARK: - UIViewController+ErrorHandling

extension UIViewController {

    func handle(error: Error?) {
        guard let error = error as NSError? else { return }

        let alertController = UIAlertController(title: "Error", message: error.localizedDescription,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }
}
