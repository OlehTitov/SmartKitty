//
//  SCClient.swift
//  SmartKitty
//
//  Created by Oleh Titov on 04.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

class SCClient {
    
    struct Auth {
        static var accountId: String = ""
        static var apiKey: String = ""
        static var authKey: String {
            let loginString = String(format: "%@:%@", accountId, apiKey)
            let loginData = loginString.data(using: String.Encoding.utf8)!
            let base64LoginString = loginData.base64EncodedString()
            return base64LoginString
        }
    }
}
