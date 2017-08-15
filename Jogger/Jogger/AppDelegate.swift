//
//  AppDelegate.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-14.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit
import Firebase

// MARK: - AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?
}

// MARK: - UIApplicationDelegate Methods

extension AppDelegate: UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        return true
    }
}
