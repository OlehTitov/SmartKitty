//
//  ToggleButton.swift
//  SmartKitty
//
//  Created by Oleh Titov on 12.08.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import UIKit
class ToggleButton: UIButton {
  @IBInspectable var highlightedSelectedImage:UIImage?
  override func awakeFromNib() {
    self.addTarget(self, action: #selector(btnClicked(_:)),
                   for: .touchUpInside)
    self.setImage(highlightedSelectedImage,
                  for: [.highlighted, .selected])
  }
  @objc func btnClicked (_ sender:UIButton) {
    isSelected.toggle()
  }
}
