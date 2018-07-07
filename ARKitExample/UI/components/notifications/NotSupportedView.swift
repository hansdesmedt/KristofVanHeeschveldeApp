//
//  NotSupportedView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 13/06/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class NotSupportedView: PopupView {
  
  @IBOutlet weak var contentLabel: UILabel!
  
  func showNotSupported() {
    contentLabel.attributedText = NSAttributedString.body(string: "Your device is not supported, ARKit is compatible with iPhone 6S and up, try to update your OS.")
  }
  
  func showNoPermissions(message: String) {
    contentLabel.attributedText = NSAttributedString.body(string: message)
  }
}
