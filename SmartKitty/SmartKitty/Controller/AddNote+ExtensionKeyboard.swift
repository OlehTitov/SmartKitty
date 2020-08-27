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
    }
    
    //Stop tracking when keyboard appears
    func unsubscribeFromKeyboardNotifications() {
        //Remove all notification without specifying exact name
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if noteTextField.isEditing {
            saveButton.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    
    @objc func keyboardWillHide(_ notification:Notification) {
        //Return button to its normal place
        saveButton.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
}
