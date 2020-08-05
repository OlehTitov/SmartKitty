//
//  LoginVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 03.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    //MARK: - PROPERTIES
    let dismissKeyboard = DismissKeyboardDelegate()
    let pickerArray = [SCClient.Servers.europe.rawValue, SCClient.Servers.america.rawValue, SCClient.Servers.asia.rawValue]
    
    //MARK: - OUTLETS
    
    @IBOutlet weak var accountIDTextfield: UITextField!
    @IBOutlet weak var apiKeyTextfield: UITextField!
    @IBOutlet weak var serverPickerView: UIPickerView!
    
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegates()
    
    }
    
    //MARK: - SETUP DELEGATES
    func setupDelegates() {
        serverPickerView.delegate = self
        apiKeyTextfield.delegate = dismissKeyboard
        accountIDTextfield.delegate = dismissKeyboard
    }

    //MARK: - LOGIN
    @IBAction func loginTapped(_ sender: Any) {
        SCClient.Auth.accountId = accountIDTextfield.text!
        SCClient.Auth.apiKey = apiKeyTextfield.text!
        SCClient.getAccountInfo(completion: handleGetAccountInfo(companyName:error:))
    }
    
    func handleGetAccountInfo(companyName: String, error: Error?) {
        print(companyName)
        SCClient.getProjectsList(completion: handleGetProjectsList(projects:error:))
    }
    
    func handleGetProjectsList(projects: [Project], error: Error?) {
        print(projects.count)
    }
    
}

//MARK: - EXTENSION: PICKER VIEW DELEGATE
extension LoginVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SCClient.selectedServer = pickerArray[row]
    }
}

