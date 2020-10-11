//
//  Alerts.swift
//  SmartKitty
//
//  Created by Oleh Titov on 09.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

enum AlertTitles: String {
    case authorizationFailed = "Login failed"
    case serverError = "SmartCat server error"
    case undefinedError = "Something went wrong"
    case notConnected = "No internet connection"
    case thankYou = "Thank you!"
    
}

enum AlertMessages: String {
    case authorizationFailed = "Please check if your account ID and API key are entered correctly"
    case serverError = "The SmartCat servers can't process our request. Please try again later"
    case undefinedError = "We can't process your request. Please try again later"
    case notConnected = "You can still browse your projects in an offline mode"
    case notConnectedNewcomer = "Please try again later"
    case unableToSendEmail = "You can still send me a regular email at oleg.titov81@gmail.com. Thank you!"
    case errorSendingEmail = "Couldn't send the email. Please try again later."
    case feedback = "Your feedback is very important to me. Thank you for your time and efforts!"
}

struct Alerts {
    static func errorAlert(title: String, message: String?, cancelButton: Bool = false, completion: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .default) {
            _ in
            guard let completion = completion else { return }
            completion()
        }
        alert.addAction(actionOK)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if cancelButton { alert.addAction(cancel) }
        
        return alert
    }
}
