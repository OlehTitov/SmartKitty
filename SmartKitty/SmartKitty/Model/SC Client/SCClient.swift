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
    static var companyName = ""
    
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
        case account = "/api/integration/v1/account/"
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
    
    class func getAccountInfo(completion: @escaping (String, Int, Error?) -> Void) {
        taskForGETRequest(url: urlComponents(path: .account), responseType: AccountResponse.self) { (response, httpResponse, error) in
            if let response = response {
                completion(response.name, httpResponse!.statusCode, nil)
            } else {
                completion("", httpResponse!.statusCode, error)
            }
        }
    }
    
    class func getProjectsList(completion: @escaping ([Project], Error?) -> Void) {
        taskForGETRequest(url: urlComponents(path: .projectsList), responseType: [Project].self) { (response, httpResponse, error)  in
            if let response = response {
                completion(response, nil)
            } else {
                print("Can't decode the projects")
                completion([], error)
            }
        }
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, HTTPURLResponse?, Error?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(Auth.authKey)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            guard let data = data else {
                DispatchQueue.main.async {
                    print(httpResponse as Any)
                    completion(nil, httpResponse, error)
                }
                return
            }
            //let str = String(decoding: data, as: UTF8.self)
            //print(str)
            //print(request.allHTTPHeaderFields!)
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, httpResponse, nil)
                }
            } catch {
                let rawServerErrorResponse = String(decoding: data, as: UTF8.self)
                let trimmedResponse = rawServerErrorResponse.trimmingCharacters(in: .whitespacesAndNewlines)
                print(trimmedResponse)
                DispatchQueue.main.async {
                    completion(nil, httpResponse, error)
                }
            }
        }
        task.resume()
        
        return task
    }
    
}
