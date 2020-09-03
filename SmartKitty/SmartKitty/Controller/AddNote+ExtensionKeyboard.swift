//
//  AddNote+ExtensionKeyboard.swift
//  SmartKitty
//
//  Created by Oleh Titov on 27.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

extension AddNote {
    
    //Start tracking when keyboard appears
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    
    //Stop tracking when keyboard appears
    func unsubscribeFromKeyboardNotifications() {
        //Remove all notification without specifying exact name
        NotificationCenter.default.removeObserver(self)
    }
    
    //Increase bottom constraint of the buttons to avoid them being covered by keyboard
    //Add extra 10 points to let the buttons stand out above the keyboard
    @objc func keyboardWillShow(_ notification:Notification) {
        if noteTextField.isEditing && buttonsBlockBottomConstraint.constant == 50 {
            buttonsBlockBottomConstraint.constant = getKeyboardHeight(notification) + 10
        }
    }
    
    
    @objc func keyboardWillHide(_ notification:Notification) {
        //Return button to its normal place
        buttonsBlockBottomConstraint.constant = 50
    }
    
    @objc func appResignActive(_ notification:Notification) {
        //Return button to its normal place
        //saveButton.frame.origin.y = 0
        //saveBottomContstraint.constant = 50
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
}
