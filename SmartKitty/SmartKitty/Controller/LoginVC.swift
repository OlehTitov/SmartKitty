//
//  LoginVC.swift
//  SmartKitty
//
//  Created by Oleh Titov on 03.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//
import Foundation
import UIKit

class LoginVC: UIViewController {

    //MARK: - PROPERTIES
    let dismissKeyboard = DismissKeyboardDelegate()
    let pickerArray = [
        SCClient.Servers.europe.rawValue,
        SCClient.Servers.america.rawValue,
        SCClient.Servers.asia.rawValue
    ]
    let signupURL = "https://smartcat.ai"
    
    //MARK: - OUTLETS
    
    @IBOutlet weak var accountIDTextfield: UITextField!
    @IBOutlet weak var apiKeyTextfield: UITextField!
    @IBOutlet weak var serverPickerView: UIPickerView!
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        serverPickerView.tintColor = UIColor.darkPrimary
        setupDelegates()
        autofillCredentials()
    }
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - SETUP DELEGATES
    func setupDelegates() {
        serverPickerView.delegate = self
        apiKeyTextfield.delegate = dismissKeyboard
        accountIDTextfield.delegate = dismissKeyboard
    }

    //MARK: - HANDLE CREDENTIALS
    func saveCredentials() {
        guard let accountId = accountIDTextfield.text, let apiKey = apiKeyTextfield.text else {
            return
        }
        print("Saving credentials")
        UserDefaults.standard.set(accountId, forKey: "AccountId")
        UserDefaults.standard.set(apiKey, forKey: "ApiKey")
        UserDefaults.standard.set(true, forKey: "CredentialsAvailable")
    }
    
    func saveCompanyName(name: String) {
        UserDefaults.standard.set(name, forKey: "CompanyName")
    }
    
    func autofillCredentials() {
        if UserDefaults.standard.bool(forKey: "CredentialsAvailable") {
            print("Trying to autofill the fields")
            accountIDTextfield.text = (UserDefaults.standard.value(forKey: "AccountId") as! String)
            apiKeyTextfield.text = (UserDefaults.standard.value(forKey: "ApiKey") as! String)
            //rememberMe.isSelected = true
        }
    }
    
    //MARK: - LOGIN
    @IBAction func loginTapped(_ sender: Any) {
        SCClient.Auth.accountId = accountIDTextfield.text!
        SCClient.Auth.apiKey = apiKeyTextfield.text!
        SCClient.getAccountInfo(completion: handleGetAccountInfo(companyName:statusCode:error:))
    }
    
    //MARK: - HANDLE LOGIN
    func handleGetAccountInfo(companyName: String, statusCode: Int, error: Error?) {
        print(statusCode)
        let httpStatusCode = HTTPStatusCodes(rawValue: statusCode)!
        switch httpStatusCode {
        case .OK:
            print(companyName)
            saveCredentials()
            saveCompanyName(name: companyName)
            goToNextVC()
        case .Unauthorized:
            showAlert(
                title: .authorizationFailed,
                message: .authorizationFailed
            )
        case .InternalServerError, .BadGateway, .ServiceUnavailable:
            showAlert(
                title: .serverError,
                message: .serverError
            )
        case .NotConnected:
            showAlert(
                title: .notConnected,
                message: .notConnected
            )
        default:
            showAlert(
                title: .undefinedError,
                message: .undefinedError
            )
        }
        
    }
    
    func showAlert(title: AlertTitles, message: AlertMessages) {
        let alert = Alerts.errorAlert(title: title.rawValue, message: message.rawValue)
        present(alert, animated: true)
    }
    
    func goToNextVC() {
        let animationVC = self.storyboard?.instantiateViewController(identifier: "LoginAnimationVC") as! LoginAnimationVC
        animationVC.modalPresentationStyle = .fullScreen
        animationVC.modalTransitionStyle = .crossDissolve
        present(animationVC, animated: true, completion: nil)
    }
 
    
    @IBAction func signupTapped(_ sender: Any) {
        let url = URL(string: signupURL)
        UIApplication.shared.open(url!, options: [ : ], completionHandler: nil)
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
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedSting = NSAttributedString(string: pickerArray[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.darkPrimary])
        return attributedSting
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SCClient.selectedServer = pickerArray[row]
    }
}

