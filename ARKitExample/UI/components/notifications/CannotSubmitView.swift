//
//  CannotSubmitView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 12/06/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class CannotSubmitView: PopupView {

  @IBOutlet weak var contentLabel: UILabel!
  
  func showMessage() {
    contentLabel.attributedText = NSAttributedString.bodyBold(string: "You have to wait 24h to submit a new photo.")
  }
}
