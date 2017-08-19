//
//  AppDelegate.swift
//  Jogger
//
//  Created by Mark DiFranco on 2017-08-14.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import UIKit
import Firebase
import SwinjectStoryboard

// MARK: - AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder {
    var window: UIWindow?

    let mainAssembler = MainAssembler()
}

// MARK: - UIApplicationDelegate Methods

extension AppDelegate: UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupWindow()

        return true
    }
}

// MARK: Private Methods

private extension AppDelegate {

    func setupWindow() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()

        let storyboard = SwinjectStoryboard.create(name: "Main", bundle: nil)

        window.backgroundColor = UIColor.white
        window.rootViewController = storyboard.instantiateInitialViewController()

        self.window = window
    }
}
