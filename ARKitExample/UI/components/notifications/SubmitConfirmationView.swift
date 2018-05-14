//
//  SubmitConfirmationView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 13/05/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class SubmitConfirmationView: PopupView {
  
  @IBOutlet weak var contentLabel: UILabel!
  
  func progress(_ newProgress:Progress) {
    let progress = round(Float(newProgress.completedUnitCount) / Float(newProgress.totalUnitCount) * 100)
    let confirmation = String.init(format: "%0.f%% submitted", progress)
    contentLabel.attributedText = NSAttributedString.body(string: confirmation)
  }
  
  func showError() {
    contentLabel.attributedText = NSAttributedString.body(string: "Oeps something went wrong!")
  }
  
  func showCompleted() {
    contentLabel.attributedText = NSAttributedString.body(string: "Completed")
  }
  
}

