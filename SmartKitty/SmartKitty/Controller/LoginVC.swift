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
    let pickerArray = [SCClient.Servers.europe.rawValue, SCClient.Servers.america.rawValue, SCClient.Servers.asia.rawValue]
    var selectedServer = SCClient.Servers.europe.rawValue
    
    //MARK: - OUTLETS
    
    @IBOutlet weak var accountIDTextfield: UITextField!
    @IBOutlet weak var apiKeyTextfield: UITextField!
    @IBOutlet weak var serverPickerView: UIPickerView!
    
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        serverPickerView.delegate = self
    }

    //MARK: - LOGIN
    @IBAction func loginTapped(_ sender: Any) {
    }
    
}

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
        selectedServer = pickerArray[row]
    }
}

