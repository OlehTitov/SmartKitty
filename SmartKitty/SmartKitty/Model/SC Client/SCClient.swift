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
    static var companyName: String = UserDefaults.standard.object(forKey: "CompanyName") as! String
    
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
        case teamMember = "/api/integration/v1/account/myTeam"
        case project = "/api/integration/v1/project"
        case client = "/api/integration/v2/client"
        case searchMyTeam = "/api/integration/v1/account/searchMyTeam"
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
        _ = taskForGETRequest(url: urlComponents(path: .account), responseType: AccountResponse.self) { (response, httpResponse, error) in
            if let err = error as? URLError, err.code == URLError.Code.notConnectedToInternet {
                print("-- Not connected to internet")
                completion("", 0, error)
            }
            
            
            if let response = response {
                completion(response.name, httpResponse!.statusCode, nil)
            } else {
                completion("", httpResponse!.statusCode, error)
            }
        }
    }
    
    class func getProjectsList(completion: @escaping ([Project], Error?) -> Void) {
        _ = taskForGETRequest(url: urlComponents(path: .projectsList), responseType: [Project].self) { (response, httpResponse, error)  in
            if let response = response {
                completion(response, nil)
            } else {
                print("Can't decode the projects")
                completion([], error)
            }
        }
    }
    
    class func getClientInfo(clientId: String, completion: @escaping (Client?, Error?) -> Void) {
        let baseUrl = urlComponents(path: .client)
        let completeUrl = baseUrl.appendingPathComponent(clientId)
        print(completeUrl)
        print(Auth.accountId)
        print(Auth.apiKey)
        _ = taskForGETRequest(url: completeUrl, responseType: Client.self, completion: { (response, httpResponse, error) in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        })
    }
    
    class func getTeamMemberInfo(userId: String, completion: @escaping (String, Error?) -> Void) {
        let baseUrl = urlComponents(path: .teamMember)
        let completeUrl = baseUrl.appendingPathComponent(userId)
        _ = taskForGETRequest(url: completeUrl, responseType: MyTeam.self) { (response, httpresponse, error) in
            if let response = response {
                let name = response.firstName ?? ""
                let lastName = response.lastName ?? ""
                let fullName = name + lastName
                completion(fullName, nil)
            } else {
                print("Can't decode freelancer name")
                print(error as Any)
                completion("", error)
            }
        }
    }
    
    class func addProjectNote(projectId: String, method: String, note: ProjectNote, completion: @escaping (Bool, Error?) -> Void) {
        let baseUrl = urlComponents(path: .project)
        let completeUrl = baseUrl.appendingPathComponent(projectId)
        print(completeUrl)
        taskForPostRequest(url: completeUrl, body: note, method: method) { (data, response, error) in
            if let response = response {
                let success: Bool = response.statusCode == 204
                print(response.statusCode)
                completion(success, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    class func searchMyTeam() {
        
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, HTTPURLResponse?, Error?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(Auth.authKey)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            print("-- HTTP RESPONSE: \(httpResponse?.statusCode ?? 0)")
            if let err = error as? URLError, err.code == URLError.Code.notConnectedToInternet {
                print("-- No Internet Connection")
                print("-- Error Code: \(err.code)")
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
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
    
    class func taskForPostRequest<RequestType: Encodable>(url: URL, body: RequestType, method: String, completion: @escaping (String?, HTTPURLResponse?, Error?) -> Void) {
        var request = URLRequest(url: url)
        //There are might be POST or PUT here
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(Auth.authKey)", forHTTPHeaderField: "Authorization")
        let body = body
        request.httpBody = try! JSONEncoder().encode(body)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            let httpResponse = response as? HTTPURLResponse
            guard let data = data else {
                DispatchQueue.main.async {
                    print(httpResponse ?? "")
                    completion(nil, httpResponse, error)
                }
                return
            }
            let rawServerResponse = String(decoding: data, as: UTF8.self)
            print(rawServerResponse)
            DispatchQueue.main.async {
                completion(rawServerResponse, httpResponse, nil)
            }
            
        }
        task.resume()
    }
    
}
