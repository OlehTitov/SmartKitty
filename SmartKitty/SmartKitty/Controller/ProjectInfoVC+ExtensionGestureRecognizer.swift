//
//  ProjectInfoVC+ExtensionGestureRecognizer.swift
//  SmartKitty
//
//  Created by Oleh Titov on 27.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

extension ProjectInfoVC: UIGestureRecognizerDelegate {
    
    //MARK: - TAP AND HOLD TO COPY TEXT FROM LABEL INTO CLIPBOARD
    
    func configureGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecognizer.delegate = self
        projectTitle.isUserInteractionEnabled = true
        projectTitle.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.minimumPressDuration = 0.7
        gestureRecognizer.numberOfTapsRequired = 0
    }
    
    @objc func handleTap(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.becomeFirstResponder()
            makeHapticFeedback()
            if let text = projectTitle.text {
                copyTextToClipBoard(source: text)
                print("-- Text: \(text) copied to clipboard")
            }
        }
        // End gesture
        sender.state = .ended
    }
    
    func copyTextToClipBoard(source: String) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = source
    }
    
    func makeHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
