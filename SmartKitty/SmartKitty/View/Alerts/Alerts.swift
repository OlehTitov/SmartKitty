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
    
}

enum AlertMessages: String {
    case authorizationFailed = "Please check if your account ID and API key are entered correctly"
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
