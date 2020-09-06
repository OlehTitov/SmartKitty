//
//  AddNote.swift
//  SmartKitty
//
//  Created by Oleh Titov on 25.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class AddNote: UIViewController, UITextFieldDelegate {
    
    //MARK: - PROPERTIES
    var selectedProject: SkProject!
    let dismissKeyboard = DismissKeyboardDelegate()
    
    //MARK: - OUTLETS
    @IBOutlet weak var buttonsBlockBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: PrimaryButton!
    @IBOutlet weak var noteTextField: UITextField!
    
    //MARK: - VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        hideNavBar(true)
        subscribeToKeyboardNotifications()
    }
    
    //MARK: - VIEW DID APPEAR
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        noteTextField.becomeFirstResponder()
    }
    
    //MARK: - VIEW WILL DISAPPEAR
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        hideNavBar(false)
        unsubscribeFromKeyboardNotifications()
    }
    
    func hideNavBar(_ hidden: Bool) {
        tabBarController?.tabBar.isTranslucent = hidden
        tabBarController?.tabBar.isHidden = hidden
    }
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        noteTextField.delegate = self
        saveButton.isEnabled = false
    }
    
    //MARK: - SAVE BUTTON TAPPED
    @IBAction func saveButtonTapped(_ sender: Any) {
        //Keep old notes
        let oldNotes = selectedProject.desc ?? ""
        //Save note text
        guard let text = noteTextField.text else {
            return
        }
        selectedProject.desc = "\(text) \n\(oldNotes)"
        try? DataController.shared.viewContext.save()
        
        //Dismiss the popup controller
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - CANCEL BUTTON TAPPED
    @IBAction func cancelTapped(_ sender: Any) {
        //Dismiss the popup controller
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - DISABLE BUTTON WHEN THERE IS NO TEXT
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if !text.isEmpty {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
        return true
    }
    
    //MARK: - HIDE KEYBOARD
    //Hide keyboard when return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

