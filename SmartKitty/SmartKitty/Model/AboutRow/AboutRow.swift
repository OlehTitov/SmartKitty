//
//  AboutRow.swift
//  SmartKitty
//
//  Created by Oleh Titov on 06.10.2020.
//  Copyright © 2020 Oleh Titov. All rights reserved.
//

import Foundation
import UIKit

struct AboutRow: Hashable {
    var title: String
    var tag: String
}

enum AboutRowTitle: String {
    case privacyPolicy = "Privacy Policy"
    case feedback = "Send feedback"
    case share = "Share"
    case developer = "Developer"
}
