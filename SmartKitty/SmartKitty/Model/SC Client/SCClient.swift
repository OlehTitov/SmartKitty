//
//  SCClient.swift
//  SmartKitty
//
//  Created by Oleh Titov on 04.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation

class SCClient {
    
    static var selectedServer = Servers.europe.rawValue
    
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
    
    enum Servers: String {
        case europe = "smartcat.ai"
        case america = "us.smartcat.ai"
        case asia = "ea.smartcat.ai"
    }
    
    enum Path: String {
        case account = "/api/integration/v1/account"
        case projectsList = "/api/integration/v1/project/list"
    }
    
    class func urlComponents(path: Path) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = selectedServer
        components.path = path.rawValue
        let url = components.url
        return url!
    }
    
}
