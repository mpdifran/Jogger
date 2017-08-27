//
//  JoggerUITests.swift
//  JoggerUITests
//
//  Created by Mark DiFranco on 2017-08-14.
//  Copyright © 2017 Mark DiFranco. All rights reserved.
//

import XCTest

class JoggerUITests: XCTestCase {
    let app = XCUIApplication()

    // MARK: - SetUp / TearDown

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        app.launch()
    }

    // MARK: - Test Methods

    func test_basicFlow() {
        // User
        tapButton(named: "Create", inNavigationBarWithTitle: "Log In")
        createAccount(withEmail: "ui@test.com", password: "password", role: "User")

        navigateToTab(named: "Jogs")
        tapButton(named: "Add", inNavigationBarWithTitle: "Jogs")
        swipeUp(numberOfTimes: 1)
        updateJog(withHours: 2, minutes: 30, distance: 18)
        tapButton(named: "Create", inNavigationBarWithTitle: "New Jog")
        verifyJogIsDisplayed(withHours: 2, minutes: 30, distance: 18)

        tapButton(named: "Add", inNavigationBarWithTitle: "Jogs")
        swipeUp(numberOfTimes: 1)
        updateJog(withHours: 3, minutes: 30, distance: 30)
        tapButton(named: "Create", inNavigationBarWithTitle: "New Jog")
        verifyJogIsDisplayed(withHours: 3, minutes: 30, distance: 30)

        navigateToTab(named: "Reports")
        verifyReportIsDisplayed(withTotalHours: 6, totalMinutes: 0, totalDistance: 48)

        navigateToTab(named: "Profile")
        verifyProfile(withEmail: "ui@test.com", role: "User")
        logOut()

        // User Manager
        tapButton(named: "Create", inNavigationBarWithTitle: "Log In")
        createAccount(withEmail: "ui+um@test.com", password: "password", role: "User Manager")

        navigateToTab(named: "Users")
        updateRoleForUser(withEmail: "ui@test.com", role: "User Manager")
        verifyRoleForUser(withEmail: "ui@test.com", role: "User Manager")
        updateRoleForUser(withEmail: "ui@test.com", role: "User")
        verifyRoleForUser(withEmail: "ui@test.com", role: "User")

        navigateToTab(named: "Profile")
        verifyProfile(withEmail: "ui+um@test.com", role: "User Manager")
        logOut()

        logIn(withEmail: "ui+um@test.com", password: "password")
        navigateToTab(named: "Profile")
        logOut()

        // Admin
        tapButton(named: "Create", inNavigationBarWithTitle: "Log In")
        createAccount(withEmail: "ui+admin@test.com", password: "password", role: "Admin")

        navigateToTab(named: "Users")
        selectUser(withEmail: "ui@test.com")
        deleteJog(at: 0)
        tapButton(named: "Users", inNavigationBarWithTitle: "Jogs")
        deleteUser(withEmail: "ui@test.com")
        deleteUser(withEmail: "ui+um@test.com")
        deleteUser(withEmail: "ui+admin@test.com")
    }

    // MARK: - Helper Methods

    func tapButton(named name: String, inNavigationBarWithTitle title: String) {
        app.navigationBars[title].buttons[name].tap()
    }

    func logIn(withEmail email: String, password: String) {
        let emailTextField = app.tables.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText(email)

        let passwordTextField = app.tables.secureTextFields["Password"]
        passwordTextField.tap()
        passwordTextField.typeText(password)

        app.tables.buttons["Log In"].tap()
    }

    func createAccount(withEmail email: String, password: String, role: String) {
        let emailTextField = app.tables.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText(email)

        let passwordTextField = app.tables.secureTextFields["Password"]
        passwordTextField.tap()
        passwordTextField.typeText(password)

        let verifyPasswordTextField = app.tables.secureTextFields["Verify Password"]
        verifyPasswordTextField.tap()
        verifyPasswordTextField.typeText(password)

        app.tables.buttons[role].tap()

        app.tables.buttons["Create Account"].tap()
    }

    func navigateToTab(named name: String) {
        app.tabBars.buttons[name].tap()
    }

    func updateJog(withHours hours: Int, minutes: Int, distance: Int) {
        let hoursTextField = app.tables.cells.containing(.staticText, identifier:"Hours")
            .children(matching: .textField).element
        hoursTextField.tap()
        hoursTextField.typeText("\(hours)")

        let minutesTextField = app.tables.cells.containing(.staticText, identifier:"Minutes")
            .children(matching: .textField).element
        minutesTextField.tap()
        minutesTextField.typeText("\(minutes)")

        let distanceTextField = app.tables.cells.containing(.staticText, identifier:"Distance (km)")
            .children(matching: .textField).element
        distanceTextField.tap()
        distanceTextField.typeText("\(distance)")
    }

    func verifyJogIsDisplayed(withHours hours: Int, minutes: Int, distance: Int) {
        XCTAssertTrue(app.tables.staticTexts["\(distance) km"].exists)
        XCTAssertTrue(app.tables.staticTexts["\(hours) hours, \(minutes) minutes"].exists)

        let averageSpeed = Float(distance) / (Float(hours) + Float(minutes) / 60)
        XCTAssertTrue(app.tables.staticTexts[String(format: "Average Speed: %.2f km/h", averageSpeed)].exists)
    }

    func verifyReportIsDisplayed(withTotalHours totalHours: Int, totalMinutes: Int, totalDistance: Int) {
        let averageSpeed = Float(totalDistance) / (Float(totalHours) + Float(totalMinutes) / 60)
        XCTAssertTrue(app.tables.staticTexts[String(format: "Average Speed: %.2f km/h", averageSpeed)].exists)
        XCTAssertTrue(app.tables.staticTexts["Total Distance: \(totalDistance) km"].exists)
    }

    func verifyProfile(withEmail email: String, role: String) {
        XCTAssertTrue(app.tables.staticTexts[email].exists)
        XCTAssertTrue(app.tables.staticTexts[role].exists)
    }

    func selectUser(withEmail email: String) {
        app.tables.staticTexts[email].tap()
    }

    func deleteJog(at index: UInt) {
        app.tables.cells.element(boundBy: index).swipeLeft()
        app.buttons["Delete"].tap()
    }

    func updateRoleForUser(withEmail email: String, role: String) {
        app.tables.cells.containing(.staticText, identifier: email).element.swipeLeft()
        app.tables.cells.containing(.staticText, identifier: email).buttons["Update Role"].tap()
        app.buttons[role].tap()
    }

    func verifyRoleForUser(withEmail email: String, role: String) {
        XCTAssertTrue(app.tables.cells.containing(.staticText, identifier: email).staticTexts[role].exists)
    }

    func deleteUser(withEmail email: String) {
        app.tables.cells.containing(.staticText, identifier: email).element.swipeLeft()
        app.buttons["Delete"].tap()
        XCTAssertFalse(app.tables.cells.containing(.staticText, identifier: email).element.exists)
    }

    func logOut() {
        app.tables.buttons["Log Out"].tap()
    }

    func swipeDown(numberOfTimes: UInt) {
        for _ in 0 ..< numberOfTimes {
            app.tables.element.swipeDown()
        }
    }

    func swipeUp(numberOfTimes: UInt) {
        for _ in 0 ..< numberOfTimes {
            app.tables.element.swipeUp()
        }
    }
}
