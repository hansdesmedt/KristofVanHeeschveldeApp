//
//  RemainingTimeView.swift
//  ARKitExample
//
//  Created by Hans De Smedt on 24/04/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class RemainingTimeView: PopupView {
  
  var latestSubmitted = Date() {
    didSet {
      calculateRemainingTime()
    }
  }
  
  @IBOutlet weak var contentLabel: UILabel!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    originX = 155
    originY = 285
    makeTransformations()
  }
  
  func calculateRemainingTime() {
    let now = Date()
    let interval = now.timeIntervalSince(latestSubmitted)
    let day: TimeInterval = 24 * 60 * 60
    let remaining = interval.distance(to: day)
    
    let ti = Int(remaining)
    
    let seconds = ti % 60
    let minutes = (ti / 60) % 60
    let hours = (ti / 3600)
    
    let remainingTime = String(format: "%0.2dh %0.2dm %0.2ds",hours,minutes,seconds)
    
    contentLabel.attributedText = NSAttributedString.H1Bold(string: remainingTime)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    contentLabel.attributedText = NSAttributedString.body(string: "Aenean cursus blandit erat eu porttitor. Mauris eu sapien sagittis, pretium massa id, dignissim risus. Sed vel fermentum sem.")
  }
}
